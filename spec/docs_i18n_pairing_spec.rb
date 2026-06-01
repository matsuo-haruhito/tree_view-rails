# frozen_string_literal: true

require "pathname"

RSpec.describe "docs i18n page pairing" do
  DOCS_LOCALES = %w[en ja].freeze
  INTENTIONALLY_ONE_SIDED_BILINGUAL_DOCS = [].freeze

  let(:docs_root) { Pathname.new(__dir__).parent.join("docs") }

  it "keeps user-facing English and Japanese docs pages paired" do
    aggregate_failures do
      DOCS_LOCALES.permutation(2) do |source_locale, target_locale|
        missing_paths = missing_paths(source_locale:, target_locale:)

        expect(missing_paths).to be_empty, <<~MESSAGE
          Missing #{target_locale} docs pages for #{source_locale} sources:
          #{missing_paths.join("\n")}
        MESSAGE
      end
    end
  end

  def page_names_for(locale)
    docs_root.join(locale).glob("*.md").map { |path| path.basename.to_s }.sort - INTENTIONALLY_ONE_SIDED_BILINGUAL_DOCS
  end

  def missing_paths(source_locale:, target_locale:)
    (page_names_for(source_locale) - page_names_for(target_locale)).map do |page_name|
      "docs/#{target_locale}/#{page_name}"
    end
  end
end
