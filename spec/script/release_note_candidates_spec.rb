# frozen_string_literal: true

require "spec_helper"
require_relative "../../script/release_note_candidates"

def build_fake_release_note_client
  Class.new do
    attr_reader :queries, :compares, :issue_numbers

    def initialize
      @queries = []
      @compares = []
      @issue_numbers = []
    end

    def search(query)
      @queries << query
      if query.include?("is:pr")
        [
          {
            "number" => 12,
            "title" => "Add toolbar helper",
            "html_url" => "https://github.com/example/repo/pull/12",
            "pull_request" => {"merged_at" => "2026-06-01T00:00:00Z"}
          }
        ]
      else
        [
          {
            "number" => 34,
            "title" => "Clarify release docs",
            "html_url" => "https://github.com/example/repo/issues/34",
            "closed_at" => "2026-06-02T00:00:00Z"
          }
        ]
      end
    end

    def compare(repo, base_ref)
      @compares << [repo, base_ref]
      {
        "commits" => [
          {"commit" => {"message" => "Merge pull request #12 from feature\n\nCloses #34"}},
          {"commit" => {"message" => "Docs update without issue reference"}}
        ]
      }
    end

    def issue(repo, number)
      @issue_numbers << [repo, number]
      case number.to_i
      when 12
        {
          "number" => 12,
          "title" => "Add toolbar helper",
          "html_url" => "https://github.com/example/repo/pull/12",
          "pull_request" => {"merged_at" => "2026-06-01T00:00:00Z"}
        }
      when 34
        {
          "number" => 34,
          "title" => "Clarify release docs",
          "html_url" => "https://github.com/example/repo/issues/34",
          "closed_at" => "2026-06-02T00:00:00Z"
        }
      end
    end
  end.new
end

RSpec.describe ReleaseNoteCandidates::Collector do
  it "collects merged pull requests and closed issues for a date window" do
    client = build_fake_release_note_client
    merged_prs, closed_issues = described_class.new(client: client).by_since_date(
      repo: "example/repo",
      since_date: "2026-06-01"
    )

    expect(client.queries).to eq([
      "repo:example/repo is:pr is:merged merged:>=2026-06-01",
      "repo:example/repo is:issue is:closed closed:>=2026-06-01"
    ])
    expect(merged_prs.map(&:number)).to eq([12])
    expect(merged_prs.first.merged_at).to eq("2026-06-01T00:00:00Z")
    expect(closed_issues.map(&:number)).to eq([34])
    expect(closed_issues.first.closed_at).to eq("2026-06-02T00:00:00Z")
  end

  it "collects referenced candidates from commits since a tag" do
    client = build_fake_release_note_client
    merged_prs, closed_issues = described_class.new(client: client).by_since_tag(
      repo: "example/repo",
      since_tag: "v0.1.0"
    )

    expect(client.compares).to eq([["example/repo", "v0.1.0"]])
    expect(client.issue_numbers).to eq([["example/repo", "12"], ["example/repo", "34"]])
    expect(merged_prs.map(&:number)).to eq([12])
    expect(closed_issues.map(&:number)).to eq([34])
  end
end

RSpec.describe ReleaseNoteCandidates::MarkdownFormatter do
  it "formats candidates without implying changelog automation" do
    markdown = described_class.new.call(
      repo: "example/repo",
      source: "closed or merged since 2026-06-01",
      merged_prs: [ReleaseNoteCandidates::Entry.new(type: :pull_request, number: 12, title: "Add toolbar helper", url: "https://github.com/example/repo/pull/12", merged_at: "2026-06-01T00:00:00Z")],
      closed_issues: []
    )

    expect(markdown).to include("# Release note candidates for example/repo")
    expect(markdown).to include("Source: closed or merged since 2026-06-01")
    expect(markdown).to include("This is a maintainer review aid. It does not rewrite CHANGELOG.md")
    expect(markdown).to include("## Merged pull requests")
    expect(markdown).to include("#12 Add toolbar helper")
    expect(markdown).to include("## Closed issues")
    expect(markdown).to include("No candidates found")
  end
end

RSpec.describe ReleaseNoteCandidates::CLI do
  it "parses the date-window source option" do
    options = described_class.parse_options([
      "--repo", "example/repo",
      "--since", "2026-06-01"
    ])

    expect(options).to eq(repo: "example/repo", since: "2026-06-01")
  end

  it "parses the since-tag source option" do
    options = described_class.parse_options([
      "--repo", "example/repo",
      "--since-tag", "v0.1.0"
    ])

    expect(options).to eq(repo: "example/repo", since_tag: "v0.1.0")
  end

  it "requires the repository option" do
    expect { described_class.parse_options(["--since", "2026-06-01"]) }.to raise_error(SystemExit)
  end

  it "requires exactly one source option" do
    expect { described_class.parse_options(["--repo", "example/repo"]) }.to raise_error(SystemExit)
    expect do
      described_class.parse_options([
        "--repo", "example/repo",
        "--since", "2026-06-01",
        "--since-tag", "v0.1.0"
      ])
    end.to raise_error(SystemExit)
  end
end
