# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "stringio"
require "tmpdir"
require_relative "../lib/tree_view/release_check"

RSpec.describe TreeView::ReleaseCheck::Runner do
  def write_file(root, relative_path, content)
    path = File.join(root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def with_fixture_root(version: "0.1.0", changelog_version: version, include_release_check: true)
    Dir.mktmpdir do |root|
      write_file(root, "lib/tree_view/version.rb", <<~RUBY)
        # frozen_string_literal: true

        module TreeView
          module Version
            STRING = "#{version}"
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

      write_file(root, "CHANGELOG.md", <<~MD)
        # Changelog

        ## #{changelog_version} - 2026-05-07
      MD

      release_body = +"# Release checklist\n\nCHANGELOG.md\n"
      release_body << "bundle exec rake release:check\n" if include_release_check

      write_file(root, "docs/en/release.md", release_body)
      write_file(root, "docs/ja/release.md", release_body)

      yield root
    end
  end

  it "accepts the current release metadata shape" do
    with_fixture_root do |root|
      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.validate_metadata! }.not_to raise_error
    end
  end

  it "fails when the changelog does not have a dated section for the current version" do
    with_fixture_root(changelog_version: "0.0.9") do |root|
      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.validate_metadata! }.to raise_error(
        TreeView::ReleaseCheck::Failure,
        /CHANGELOG\.md must include a dated section for 0\.1\.0/
      )
    end
  end

  it "fails when the release docs do not mention the release check command" do
    with_fixture_root(include_release_check: false) do |root|
      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.validate_metadata! }.to raise_error(
        TreeView::ReleaseCheck::Failure,
        /bundle exec rake release:check/
      )
    end
  end

  it "skips tag verification before the release tag exists" do
    with_fixture_root do |root|
      output = StringIO.new
      runner = described_class.new(root: root, stdout: output, verify_package: false)

      expect { runner.run! }.not_to raise_error
      expect(output.string).to include("Skipping tag alignment check because v0.1.0 does not exist yet")
    end
  end
end
