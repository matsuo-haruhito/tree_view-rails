# frozen_string_literal: true

require "pathname"
require "spec_helper"

module DocsPageSetParitySpec
  ROOT = Pathname.new(File.expand_path("../docs", __dir__))
  LANGUAGES = %w[en ja].freeze

  DOCUMENTED_EXCEPTIONS = {
    "en" => [].freeze,
    "ja" => [].freeze
  }.freeze

  module_function

  def markdown_pages(language)
    Dir.glob(ROOT.join(language, "**/*.md")).map do |path|
      Pathname.new(path).relative_path_from(ROOT.join(language)).to_s
    end.sort
  end

  def exceptions_for(language)
    DOCUMENTED_EXCEPTIONS.fetch(language)
  end
end

RSpec.describe "documentation page-set parity" do
  it "keeps English and Japanese Markdown page filenames aligned" do
    english_pages = DocsPageSetParitySpec.markdown_pages("en")
    japanese_pages = DocsPageSetParitySpec.markdown_pages("ja")

    missing_in_japanese = english_pages - japanese_pages - DocsPageSetParitySpec.exceptions_for("ja")
    missing_in_english = japanese_pages - english_pages - DocsPageSetParitySpec.exceptions_for("en")

    aggregate_failures do
      expect(missing_in_japanese).to eq([])
      expect(missing_in_english).to eq([])
    end
  end

  it "keeps documented parity exceptions tied to one-sided pages" do
    english_pages = DocsPageSetParitySpec.markdown_pages("en")
    japanese_pages = DocsPageSetParitySpec.markdown_pages("ja")

    english_only_pages = english_pages - japanese_pages
    japanese_only_pages = japanese_pages - english_pages

    aggregate_failures do
      expect(DocsPageSetParitySpec.exceptions_for("ja") - english_only_pages).to eq([])
      expect(DocsPageSetParitySpec.exceptions_for("en") - japanese_only_pages).to eq([])
    end
  end
end
