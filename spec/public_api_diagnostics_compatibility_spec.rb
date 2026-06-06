# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Diagnostics public API compatibility" do
  let(:manifest_path) { File.expand_path("../config/public_api_manifest.yml", __dir__) }
  let(:diagnostics_manifest) { YAML.safe_load_file(manifest_path).fetch("diagnostics") }

  it "keeps Diagnostics accepted checks aligned with the manifest" do
    expect(diagnostics_manifest.fetch("accepted_checks")).to eq(TreeView::Diagnostics::DEFAULT_CHECKS.map(&:to_s))
  end

  it "keeps Diagnostics::Result reader surface aligned with the manifest" do
    result = TreeView::Diagnostics::Result.new(checks: [], errors: [], warnings: [])

    diagnostics_manifest.fetch("result_surface").fetch("attributes").each do |attribute_name|
      expect(result).to respond_to(attribute_name.to_sym),
        "expected TreeView::Diagnostics::Result##{attribute_name} to remain public"
    end

    diagnostics_manifest.fetch("result_surface").fetch("methods").each do |method_name|
      expect(result).to respond_to(method_name.to_sym),
        "expected TreeView::Diagnostics::Result##{method_name} to remain public"
    end

    expect(result.success?).to eq(true)

    failed_result = TreeView::Diagnostics::Result.new(
      checks: [:node_keys],
      errors: [{check: :node_keys, message: "duplicate node key"}],
      warnings: []
    )

    expect(failed_result.success?).to eq(false)
  end
end
