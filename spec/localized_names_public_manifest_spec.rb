# frozen_string_literal: true

require "spec_helper"
require "yaml"

LOCALIZED_NAMES_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
LOCALIZED_NAMES_DOC_PATHS = [
  File.expand_path("../docs/en/localized-names.md", __dir__),
  File.expand_path("../docs/ja/localized-names.md", __dir__)
].freeze

RSpec.describe "LocalizedNames public manifest" do
  def localized_name_contract
    YAML.safe_load_file(LOCALIZED_NAMES_MANIFEST_PATH).fetch("localized_name_i18n_keys")
  end

  def localized_name_docs
    LOCALIZED_NAMES_DOC_PATHS.map { |path| File.read(path) }
  end

  it "records the public localized display-name helper lookup families" do
    expect(localized_name_contract).to eq(
      "model_names" => {
        "helper" => "model_name_for",
        "delegated_lookup_prefixes" => %w[activerecord.models activemodel.models],
        "fallback" => "humanized_class_name_or_default"
      },
      "attribute_names" => {
        "helper" => "attribute_name_for",
        "delegated_lookup_prefixes" => %w[activerecord.attributes activemodel.attributes],
        "fallback" => "humanized_attribute_name_or_default"
      },
      "node_type_names" => {
        "helper" => "type_name_for",
        "lookup_prefix" => "tree_view.node_types",
        "fallback" => "humanized_node_type_or_default"
      }
    )
  end

  it "keeps top-level helper methods aligned with the manifest helper names" do
    helper_names = localized_name_contract.values.map { |contract| contract.fetch("helper") }

    expect(helper_names).to eq(%w[model_name_for attribute_name_for type_name_for])
    helper_names.each do |helper_name|
      expect(TreeView).to respond_to(helper_name.to_sym), "expected TreeView.#{helper_name} to remain public"
    end
  end

  it "keeps localized-name docs aligned with manifest-backed lookup signals" do
    localized_name_docs.each do |doc_source|
      expect(doc_source).to include("activerecord.models")
      expect(doc_source).to include("activemodel.models")
      expect(doc_source).to include("activerecord.attributes")
      expect(doc_source).to include("activemodel.attributes")
      expect(doc_source).to include("tree_view.node_types")
      expect(doc_source).to include("manifest")
    end
  end
end
