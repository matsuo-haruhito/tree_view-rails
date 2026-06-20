# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Public CSS custom property tokens" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:manifest) { YAML.safe_load_file(File.join(repo_root, "config/public_api_manifest.yml")) }
  let(:manifest_tokens) { manifest.fetch("css_custom_property_tokens") }
  let(:stylesheet) { File.read(File.join(repo_root, "app/assets/stylesheets/tree_view.scss")) }
  let(:english_docs) { File.read(File.join(repo_root, "docs/en/styling-state-cues.md")) }
  let(:japanese_docs) { File.read(File.join(repo_root, "docs/ja/styling-state-cues.md")) }

  it "keeps the manifest token list aligned with packaged stylesheet variable fallbacks" do
    stylesheet_tokens = stylesheet.scan(/var\((--tree-view-[\w-]+)\s*,/).flatten.uniq

    expect(manifest_tokens.sort).to eq(stylesheet_tokens.sort),
      "expected css_custom_property_tokens to match tree_view.scss var(--tree-view-*, fallback) usage"
  end

  it "keeps every manifest token documented in both state-cue guides" do
    manifest_tokens.each do |token|
      expect(english_docs).to include("`#{token}`"), "expected docs/en/styling-state-cues.md to document #{token}"
      expect(japanese_docs).to include("`#{token}`"), "expected docs/ja/styling-state-cues.md to document #{token}"
    end
  end

  it "keeps the styling guides from documenting tokens outside the manifest contract" do
    [
      ["docs/en/styling-state-cues.md", english_docs],
      ["docs/ja/styling-state-cues.md", japanese_docs]
    ].each do |relative_path, document|
      documented_tokens = document.scan(/`(--tree-view-[\w-]+)`/).flatten.uniq

      expect(documented_tokens).to eq(manifest_tokens),
        "expected #{relative_path} Documented tokens table to stay aligned with css_custom_property_tokens"
    end
  end
end
