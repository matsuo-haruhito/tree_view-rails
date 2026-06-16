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

  def run_command(*command, chdir: nil)
    success =
      if chdir
        Dir.chdir(chdir) { system(*command) }
      else
        system(*command)
      end

    raise "command failed: #{command.join(" ")}" unless success
  end

  def initialize_git_repo(root)
    run_command("git", "init", "-q", chdir: root)
    run_command("git", "config", "user.name", "TreeView test", chdir: root)
    run_command("git", "config", "user.email", "tree-view@example.com", chdir: root)
    run_command("git", "add", ".", chdir: root)
    run_command("git", "commit", "-q", "-m", "Initial fixture", chdir: root)
  end

  def with_fixture_root(version: "0.1.0", changelog_version: version, changelog_body: nil, include_release_check: true)
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

      write_file(root, "lib/tree_view.rb", <<~RUBY)
        # frozen_string_literal: true

        require_relative "tree_view/version"
      RUBY

      write_file(root, "tree_view.gemspec", <<~RUBY)
        # frozen_string_literal: true

        require_relative "lib/tree_view/version"

        Gem::Specification.new do |spec|
          spec.name = "tree_view"
          spec.version = TreeView::VERSION
        end
      RUBY

      changelog_body ||= <<~MD
        ### Fixed

        - Keep release notes visible for the release.
      MD
      write_file(root, "CHANGELOG.md", <<~MD)
        # Changelog

        ## #{changelog_version} - 2026-05-07

        #{changelog_body}
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

  it "accepts release notes that only use the Tests category" do
    with_fixture_root(changelog_body: <<~MD) do |root|
      ### Tests

      - Keep release verification evidence visible for the release.
    MD
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

  it "fails when the changelog release section has no allowed category heading" do
    with_fixture_root(changelog_body: "- Keep release notes visible.\n") do |root|
      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.validate_metadata! }.to raise_error(
        TreeView::ReleaseCheck::Failure,
        /category heading/
      )
    end
  end

  it "fails when the changelog release section has a category heading but no release notes" do
    with_fixture_root(changelog_body: "### Documentation\n") do |root|
      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.validate_metadata! }.to raise_error(
        TreeView::ReleaseCheck::Failure,
        /release notes/
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

  it "verifies the packaged library load without relying on the parent TreeView::VERSION constant" do
    with_fixture_root do |root|
      runner = described_class.new(root: root, stdout: StringIO.new)

      hide_const("TreeView::VERSION")
      allow(runner).to receive(:build_gem!).and_return("tree_view-0.1.0.gem")
      allow(runner).to receive(:verify_packaged_files!).with("tree_view-0.1.0.gem")
      expect(runner).to receive(:verify_package_contents!).with("tree_view-0.1.0.gem")

      expect { runner.send(:verify_package!) }.not_to raise_error
    end
  end

  it "accepts an annotated release tag that points to HEAD" do
    with_fixture_root do |root|
      initialize_git_repo(root)
      run_command("git", "tag", "-a", "v0.1.0", "-m", "Release 0.1.0", chdir: root)

      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.run! }.not_to raise_error
    end
  end

  it "fails when the release tag points to a different commit" do
    with_fixture_root do |root|
      initialize_git_repo(root)
      run_command("git", "tag", "-a", "v0.1.0", "-m", "Release 0.1.0", chdir: root)
      write_file(root, "README.md", "fixture update\n")
      run_command("git", "add", "README.md", chdir: root)
      run_command("git", "commit", "-q", "-m", "Advance HEAD", chdir: root)

      runner = described_class.new(root: root, stdout: StringIO.new, verify_package: false)

      expect { runner.run! }.to raise_error(
        TreeView::ReleaseCheck::Failure,
        /v0\.1\.0 points to .* expected .*/
      )
    end
  end
end
