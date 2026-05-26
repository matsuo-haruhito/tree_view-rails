# frozen_string_literal: true

require "open3"
require "rbconfig"
require "rubygems/package"

module TreeView
  module ReleaseCheck
    ROOT = File.expand_path("../..", __dir__)
    VERSION_PATH = "lib/tree_view/version.rb"
    GEMSPEC_PATH = "tree_view.gemspec"
    CHANGELOG_PATH = "CHANGELOG.md"
    RELEASE_DOC_PATHS = %w[docs/en/release.md docs/ja/release.md].freeze

    class Failure < StandardError; end

    class Runner
      attr_reader :root, :stdout, :verify_package, :require_release_tag

      def initialize(root: ROOT, stdout: $stdout, verify_package: true, require_release_tag: ENV["TREE_VIEW_REQUIRE_RELEASE_TAG"] == "1")
        @root = root
        @stdout = stdout
        @verify_package = verify_package
        @require_release_tag = require_release_tag
      end

      def run!
        validate_metadata!
        verify_package! if verify_package
        verify_tag_alignment!
        stdout.puts("release:check passed for #{version}")
        true
      end

      def validate_metadata!
        ensure_gemspec_uses_version_constant!
        ensure_changelog_has_release_section!
        ensure_release_docs_reference_checklist!
        true
      end

      def version
        @version ||= begin
          match = read(VERSION_PATH).match(/STRING\s*=\s*"([^"]+)"/)
          raise Failure, "#{VERSION_PATH} must define TreeView::Version::STRING" unless match

          match[1]
        end
      end

      private

      def path(relative_path)
        File.join(root, relative_path)
      end

      def read(relative_path)
        File.read(path(relative_path))
      end

      def ensure_gemspec_uses_version_constant!
        source = read(GEMSPEC_PATH)
        return if source.include?("spec.version = TreeView::VERSION")

        raise Failure, "#{GEMSPEC_PATH} must set spec.version from TreeView::VERSION"
      end

      def ensure_changelog_has_release_section!
        header = /^##\s+#{Regexp.escape(version)}\s+-\s+\d{4}-\d{2}-\d{2}$/
        return if read(CHANGELOG_PATH).match?(header)

        raise Failure, "#{CHANGELOG_PATH} must include a dated section for #{version}"
      end

      def ensure_release_docs_reference_checklist!
        RELEASE_DOC_PATHS.each do |relative_path|
          source = read(relative_path)
          unless source.include?("bundle exec rake release:check")
            raise Failure, "#{relative_path} must mention `bundle exec rake release:check`"
          end

          next if source.include?("CHANGELOG.md")

          raise Failure, "#{relative_path} must mention CHANGELOG.md in the release checklist"
        end
      end

      def verify_package!
        gem_file_name = build_gem!
        verify_packaged_files!(gem_file_name)
        verify_library_load!
      end

      def build_gem!
        stdout.puts("Building #{GEMSPEC_PATH}")

        Dir.chdir(root) do
          specification = Gem::Specification.load(GEMSPEC_PATH)
          raise Failure, "Could not load #{GEMSPEC_PATH}" unless specification

          Gem::Package.build(specification)
        end
      rescue => e
        raise Failure, "gem build failed: #{e.message}"
      end

      def verify_packaged_files!(gem_file_name)
        package = Gem::Package.new(path(gem_file_name))
        files = package.spec.files

        missing = []
        missing << "README.md" unless files.include?("README.md")
        missing << "CHANGELOG.md" unless files.include?("CHANGELOG.md")
        missing << "tree_view.gemspec" unless files.include?("tree_view.gemspec")
        missing << "docs/**/*" unless files.any? { |entry| entry.start_with?("docs/") }
        missing << "LICENSE*" unless files.any? { |entry| File.basename(entry).start_with?("LICENSE") }

        return if missing.empty?

        raise Failure, "built gem is missing required release files: #{missing.join(", ")}"
      end

      def verify_library_load!
        stdout.puts("Running bundle exec ruby -Ilib load check")

        success = Dir.chdir(root) do
          system(
            "bundle",
            "exec",
            RbConfig.ruby,
            "-Ilib",
            "-e",
            %(require "tree_view"; abort("expected #{version}, got #{TreeView::VERSION}") unless TreeView::VERSION == "#{version}")
          )
        end

        return if success

        raise Failure, "bundle exec ruby -Ilib load check failed"
      end

      def verify_tag_alignment!
        tag_name = "v#{version}"
        tag_sha = git_commit_sha("refs/tags/#{tag_name}")

        if tag_sha.nil?
          raise Failure, "expected git tag #{tag_name} to exist" if require_release_tag

          stdout.puts("Skipping tag alignment check because #{tag_name} does not exist yet")
          return
        end

        head_sha = git_commit_sha("HEAD")
        return if head_sha == tag_sha

        raise Failure, "#{tag_name} points to #{tag_sha}, expected #{head_sha}"
      end

      def git_commit_sha(ref)
        stdout_string, _stderr_string, status = Open3.capture3("git", "-C", root, "rev-parse", "-q", "--verify", "#{ref}^{commit}")
        return nil unless status.success?

        stdout_string.strip
      end
    end

    def self.run!(**kwargs)
      Runner.new(**kwargs).run!
    end
  end
end
