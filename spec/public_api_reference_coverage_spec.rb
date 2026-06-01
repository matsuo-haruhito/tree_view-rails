# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_API_REFERENCE_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
PUBLIC_API_REFERENCE_DOC_PATHS = {
  "English" => File.expand_path("../docs/en/api.md", __dir__),
  "Japanese" => File.expand_path("../docs/ja/api.md", __dir__)
}.freeze

# Some public constants are intentionally documented through stable API-reference
# section names or linked guide labels instead of the literal Ruby constant token.
PUBLIC_API_REFERENCE_SIGNAL_OVERRIDES = {
  "LocalizedNames" => ["TreeView localized names", "Localized names"],
  "GraphAdapter" => ["TreeView::GraphAdapter", "adapter mode"],
  "NodePresenter" => ["NodePresenter"],
  "PathTree" => ["TreeView::PathTree", "path_tree_for(items)", "PathTree"],
  "ReverseTree" => ["ReverseTree", "reverse_tree_for(items)"],
  "Diagnostics" => ["Tree diagnostics"]
}.freeze

# Keep omissions narrow and named so a future API-reference section can remove the
# exception instead of silently letting manifest/docs drift grow.
PUBLIC_API_REFERENCE_OMISSIONS = {
  "ResourceTableRenderState" => "Resource-table integration is documented in focused resource-table guides; api.md does not yet expose a dedicated Ruby API section for this state object."
}.freeze

RSpec.describe "Public API reference coverage" do
  def public_api_reference_manifest
    @public_api_reference_manifest ||= YAML.safe_load_file(PUBLIC_API_REFERENCE_MANIFEST_PATH)
  end

  def public_api_reference_docs
    @public_api_reference_docs ||= PUBLIC_API_REFERENCE_DOC_PATHS.transform_values { |path| File.read(path) }
  end

  def public_constant_reference_signals(constant_name)
    (["TreeView::#{constant_name}"] + PUBLIC_API_REFERENCE_SIGNAL_OVERRIDES.fetch(constant_name, [])).uniq
  end

  it "keeps manifest public constants traceable from the English and Japanese API references" do
    constants = public_api_reference_manifest.fetch("public_constants")

    public_api_reference_docs.each do |locale, source|
      constants.each do |constant_name|
        next if PUBLIC_API_REFERENCE_OMISSIONS.key?(constant_name)

        signals = public_constant_reference_signals(constant_name)

        expect(signals.any? { |signal| source.include?(signal) }).to be(true),
          "expected #{locale} API reference to mention #{constant_name} using one of: #{signals.join(", ")}"
      end
    end
  end

  it "keeps intentionally omitted public constants explicit" do
    constants = public_api_reference_manifest.fetch("public_constants")

    expect(PUBLIC_API_REFERENCE_OMISSIONS.keys).to all(satisfy { |constant_name| constants.include?(constant_name) })
  end
end
