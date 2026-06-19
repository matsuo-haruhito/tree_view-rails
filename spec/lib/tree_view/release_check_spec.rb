# frozen_string_literal: true

require "fileutils"
require "stringio"
require "tmpdir"
require "spec_helper"
require "tree_view/release_check"

RSpec.describe TreeView::ReleaseCheck::Runner do
  let(:stdout) { StringIO.new }

  describe "metadata validation" do
    it "passes with a minimal aligned release fixture" do
      with_release_root do |root|
        runner = build_runner(root)

        expect(runner.validate_metadata!).to be(true)
      end
    end

    it "fails when the current version has no dated CHANGELOG section" do
      with_release_root do |root|
        write_file(root, "CHANGELOG.md", <<~MARKDOWN)
          # Changelog

          ## Unreleased

          ### Fixed

          - Pending release notes.
        MARKDOWN

        expect { build_runner(root).validate_metadata! }
          .to raise_error(
            TreeView::ReleaseCheck::Failure,
            /CHANGELOG\.md must include a dated section for 0\.1\.0/
          )
      end
    end

    it "fails when the current CHANGELOG section has no allowed category heading" do
      with_release_root do |root|
        write_file(root, "CHANGELOG.md", <<~MARKDOWN)
          # Changelog

          ## 0.1.0 - 2026-06-19

          #### Internal

          - Prepared release notes.
        MARKDOWN

        expect { build_runner(root).validate_metadata! }
          .to raise_error(
            TreeView::ReleaseCheck::Failure,
            /release section for 0\.1\.0 must include at least one category heading/
          )
      end
    end

    it "fails when the current CHANGELOG section has no release notes body" do
      with_release_root do |root|
        write_file(root, "CHANGELOG.md", <<~MARKDOWN)
          # Changelog

          ## 0.1.0 - 2026-06-19

          ### Fixed
        MARKDOWN

        expect { build_runner(root).validate_metadata! }
          .to raise_error(
            TreeView::ReleaseCheck::Failure,
            /release section for 0\.1\.0 must include release notes under a category heading/
          )
      end
    end

    %w[docs/en/release.md docs/ja/release.md].each do |relative_path|
      it "fails when #{relative_path} omits the release check command" do
        with_release_root do |root|
          write_file(root, relative_path, <<~MARKDOWN)
            # Release checklist

            Review CHANGELOG.md before release.
          MARKDOWN

          expect { build_runner(root).validate_metadata! }
            .to raise_error(
              TreeView::ReleaseCheck::Failure,
              /#{Regexp.escape(relative_path)} must mention `bundle exec rake release:check`/
            )
        end
      end

      it "fails when #{relative_path} omits the CHANGELOG reference" do
        with_release_root do |root|
          write_file(root, relative_path, <<~MARKDOWN)
            # Release checklist

            Run `bundle exec rake release:check` before release.
          MARKDOWN

          expect { build_runner(root).validate_metadata! }
            .to raise_error(
              TreeView::ReleaseCheck::Failure,
              /#{Regexp.escape(relative_path)} must mention CHANGELOG\.md in the release checklist/
            )
        end
      end
    end
  end

  describe "tag alignment" do
    it "skips tag alignment when the release tag does not exist yet" do
      with_release_root do |root|
        runner = build_runner(root, verify_package: false, require_release_tag: false)
        allow(runner).to receive(:git_commit_sha).with("refs/tags/v0.1.0").and_return(nil)

        expect(runner.run!).to be(true)
        expect(stdout.string).to include("Skipping tag alignment check because v0.1.0 does not exist yet")
        expect(stdout.string).to include("release:check passed for 0.1.0")
      end
    end

    it "fails when the release tag is required but missing" do
      with_release_root do |root|
        runner = build_runner(root, verify_package: false, require_release_tag: true)
        allow(runner).to receive(:git_commit_sha).with("refs/tags/v0.1.0").and_return(nil)

        expect { runner.run! }
          .to raise_error(TreeView::ReleaseCheck::Failure, /expected git tag v0\.1\.0 to exist/)
      end
    end

    it "fails when the release tag points at a different commit from HEAD" do
      with_release_root do |root|
        runner = build_runner(root, verify_package: false, require_release_tag: true)
        allow(runner).to receive(:git_commit_sha).with("refs/tags/v0.1.0").and_return("tag-sha")
        allow(runner).to receive(:git_commit_sha).with("HEAD").and_return("head-sha")

        expect { runner.run! }
          .to raise_error(TreeView::ReleaseCheck::Failure, /v0\.1\.0 points to tag-sha, expected head-sha/)
      end
    end
  end

  def build_runner(root, **options)
    described_class.new(root: root, stdout: stdout, **options)
  end

  def with_release_root
    Dir.mktmpdir("tree-view-release-check") do |root|
      write_release_fixture(root)
      yield root
    end
  end

  def write_release_fixture(root)
    write_file(root, "lib/tree_view/version.rb", <<~RUBY)
      # frozen_string_literal: true

      module TreeView
        module Version
          STRING = "0.1.0"
        end

        VERSION = Version::STRING
      end
    RUBY

    write_file(root, "tree_view.gemspec", <<~RUBY)
      # frozen_string_literal: true

      require_relative "lib/tree_view/version"

      Gem::Specification.new do |spec|
        spec.name = "tree_view"
        spec.version = TreeView::VERSION
      end
    RUBY

    write_file(root, "CHANGELOG.md", <<~MARKDOWN)
      # Changelog

      ## 0.1.0 - 2026-06-19

      ### Fixed

      - Prepared release metadata validation.
    MARKDOWN

    TreeView::ReleaseCheck::RELEASE_DOC_PATHS.each do |relative_path|
      write_file(root, relative_path, <<~MARKDOWN)
        # Release checklist

        Run `bundle exec rake release:check` and review CHANGELOG.md before release.
      MARKDOWN
    end
  end

  def write_file(root, relative_path, content)
    full_path = File.join(root, relative_path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.write(full_path, content)
  end
end
