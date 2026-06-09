# frozen_string_literal: true

require "spec_helper"
require "uri"

RSpec.describe "documentation local links" do
  def repo_path(relative_path = nil)
    root = File.expand_path("..", __dir__)
    relative_path ? File.join(root, relative_path) : root
  end

  def markdown_files
    ["README.md"] + Dir.glob(repo_path("docs/**/*.md")).map { |path| path.delete_prefix("#{repo_path}/") }.sort
  end

  def markdown_without_code_blocks(source)
    source.gsub(/```.*?```/m, "")
  end

  def link_target(raw_target)
    target = raw_target.strip

    if target.start_with?("<")
      target[/\A<([^>]*)>/, 1]
    else
      target.split(/\s+/, 2).first
    end
  end

  def local_target?(target)
    return false if target.nil? || target.empty?
    return false if target.start_with?("#")
    return false if target.start_with?("//")
    return false if target.match?(/\A[a-z][a-z0-9+.-]*:/i)

    true
  end

  def local_links(source)
    body = markdown_without_code_blocks(source)
    links = []

    body.scan(/(?<!!)\[[^\]\n]+\]\(([^)]+)\)/) do |match|
      target = link_target(match.first)
      links << target if local_target?(target)
    end

    body.scan(/^\s{0,3}\[[^\]\n]+\]:\s*(\S+)/) do |match|
      target = link_target(match.first)
      links << target if local_target?(target)
    end

    links
  end

  def target_exists?(source_path, target)
    path_part = target.split("#", 2).first.split("?", 2).first
    decoded_path = URI::DEFAULT_PARSER.unescape(path_part)
    resolved_path = File.expand_path(decoded_path, File.dirname(repo_path(source_path)))
    root = repo_path

    resolved_path == root || resolved_path.start_with?("#{root}/") && File.exist?(resolved_path)
  end

  it "keeps README and Markdown docs local relative links pointed at existing repository files" do
    missing_links = []

    markdown_files.each do |source_path|
      source = File.read(repo_path(source_path))

      local_links(source).each do |target|
        next if target_exists?(source_path, target)

        missing_links << "#{source_path} -> #{target}"
      end
    end

    expect(missing_links).to be_empty, "Missing local Markdown link targets:\n#{missing_links.join("\n")}"
  end
end
