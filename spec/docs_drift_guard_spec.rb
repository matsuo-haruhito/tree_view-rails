# frozen_string_literal: true

RSpec.describe "documentation drift guards" do
  ROOT = File.expand_path("..", __dir__)

  def read_repo_file(path)
    File.read(File.join(ROOT, path))
  end

  def expect_link(markdown, target, source_path)
    expect(markdown).to include("(#{target})"), "expected #{source_path} to link #{target}"
  end

  def high_lane_paths
    audit = read_repo_file("docs/i18n-audit.md")

    audit.each_line.filter_map do |line|
      next unless line.include?("| High |")

      line.scan(/`([^`]+)`/).flatten
    end.flatten.uniq
  end

  it "keeps i18n High lane pages present and reachable from docs entry points" do
    paths = high_lane_paths

    expect(paths).to include(
      "docs/README.md",
      "docs/en/README.md",
      "docs/ja/README.md",
      "docs/en/installation.md",
      "docs/ja/installation.md",
      "docs/en/minimal-usage.md",
      "docs/ja/minimal-usage.md",
      "docs/en/usage.md",
      "docs/ja/usage.md",
      "docs/en/api-overview.md",
      "docs/ja/api-overview.md"
    )

    paths.each do |path|
      expect(File).to exist(File.join(ROOT, path)), "expected i18n High lane doc to exist: #{path}"
    end

    root_docs = read_repo_file("docs/README.md")
    expect_link(root_docs, "en/README.md", "docs/README.md")
    expect_link(root_docs, "ja/README.md", "docs/README.md")
    expect_link(root_docs, "i18n-audit.md", "docs/README.md")

    {
      "docs/en/README.md" => paths.grep(%r{\Adocs/en/}).map { |path| path.delete_prefix("docs/en/") },
      "docs/ja/README.md" => paths.grep(%r{\Adocs/ja/}).map { |path| path.delete_prefix("docs/ja/") }
    }.each do |entry_path, linked_paths|
      entry = read_repo_file(entry_path)

      linked_paths.each do |target|
        expect_link(entry, target, entry_path)
      end
    end
  end

  it "keeps documented Ruby and Rails minimum versions aligned with the gemspec" do
    gemspec = read_repo_file("tree_view.gemspec")
    ruby_version = gemspec.match(/required_ruby_version = ">= ([^"]+)"/)[1]
    rails_version = gemspec.match(/add_dependency "railties", ">= ([^"]+)"/)[1]

    expectations = {
      "README.md" => ["Ruby #{ruby_version} or later", "Rails #{rails_version} or later"],
      "docs/en/installation.md" => ["Ruby #{ruby_version} or later", "Rails #{rails_version} or later"],
      "docs/ja/installation.md" => ["Ruby #{ruby_version} 以上", "Rails #{rails_version} 以上"]
    }

    expectations.each do |path, phrases|
      content = read_repo_file(path)

      phrases.each do |phrase|
        expect(content).to include(phrase), "expected #{path} to document #{phrase} from tree_view.gemspec"
      end
    end
  end
end
