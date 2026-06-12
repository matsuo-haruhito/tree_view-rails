# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_API_FILTERED_TREE_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
PUBLIC_API_FILTERED_TREE_DOC_PATHS = [
  File.expand_path("../docs/en/filtered-trees.md", __dir__),
  File.expand_path("../docs/ja/filtered-trees.md", __dir__)
].freeze

RSpec.describe "FilteredTree public mode contract" do
  def manifest_modes
    YAML.safe_load_file(PUBLIC_API_FILTERED_TREE_MANIFEST_PATH).fetch("filtered_tree_modes")
  end

  def runtime_modes
    TreeView::FilteredTree::VALID_MODES.map(&:to_s)
  end

  it "keeps manifest modes aligned with TreeView::FilteredTree::VALID_MODES" do
    expect(manifest_modes).to eq(%w[
      matched_only
      with_ancestors
      with_descendants
      with_ancestors_and_descendants
    ])
    expect(manifest_modes).to eq(runtime_modes)
  end

  it "keeps filtered-tree docs aligned with the manifest-backed mode set" do
    PUBLIC_API_FILTERED_TREE_DOC_PATHS.each do |doc_path|
      source = File.read(doc_path)

      expect(source).to include("manifest-backed")

      manifest_modes.each do |mode|
        expect(source).to include("| `:#{mode}` |"),
          "expected #{doc_path} to document the FilteredTree mode #{mode.inspect}"
      end
    end
  end
end
