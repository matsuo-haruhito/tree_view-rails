# frozen_string_literal: true

require "spec_helper"

RSpec.describe "documentation entrypoint smoke" do
  def repo_path(relative_path)
    File.expand_path("../#{relative_path}", __dir__)
  end

  def read(relative_path)
    File.read(repo_path(relative_path))
  end

  def expect_relative_link(source_path, href)
    source = read(source_path)
    target = href.split("#", 2).first
    resolved_target = File.expand_path(target, File.dirname(repo_path(source_path)))

    expect(source).to include(href)
    expect(File.file?(resolved_target)).to be(true)
  end

  def expect_ordered_signals(source_path, *signals)
    pattern = signals.map { |signal| Regexp.escape(signal) }.join("[\\s\\S]*")

    expect(read(source_path)).to match(Regexp.new(pattern))
  end

  it "keeps cookbook common pattern entrypoints and boundary signals visible" do
    [
      ["README.md", "docs/en/cookbook.md"],
      ["README.md", "docs/ja/cookbook.md"],
      ["docs/README.md", "en/cookbook.md"],
      ["docs/README.md", "ja/cookbook.md"],
      ["docs/en/README.md", "cookbook.md"],
      ["docs/ja/README.md", "cookbook.md"]
    ].each do |source_path, href|
      expect_relative_link(source_path, href)
    end

    expect_ordered_signals(
      "docs/en/cookbook.md",
      "Row customization quick guide",
      "`row_partial`",
      "`row_actions_partial`",
      "Routes, controller actions, authorization, confirmation text",
      "final copy"
    )
    expect_ordered_signals(
      "docs/ja/cookbook.md",
      "行customization quick guide",
      "`row_partial`",
      "`row_actions_partial`",
      "route、controller action、authorization、confirm文言",
      "最終copy"
    )
  end

  it "keeps children pagination visual review and host-app boundary signals visible" do
    [
      ["docs/en/children-pagination.md", "../mockups/children-pagination.html"],
      ["docs/en/children-pagination.md", "../mockups/children-pagination-selection-boundary.html"],
      ["docs/ja/children-pagination.md", "../mockups/children-pagination.html"],
      ["docs/ja/children-pagination.md", "../mockups/children-pagination-selection-boundary.html"]
    ].each do |source_path, href|
      expect_relative_link(source_path, href)
    end

    expect_ordered_signals(
      "docs/en/children-pagination.md",
      "cursor encoding",
      "Turbo Stream responses",
      "retry behavior",
      "unloaded descendants"
    )
    expect_ordered_signals(
      "docs/ja/children-pagination.md",
      "cursor encoding",
      "Turbo Stream response",
      "retry behavior",
      "unloaded descendants"
    )
  end
end
