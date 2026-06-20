# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "TreeView transfer package-root exports" do
  let(:manifest) do
    YAML.safe_load_file(File.expand_path("../../config/public_api_manifest.yml", __dir__))
  end

  let(:entrypoint_source) do
    File.read(File.expand_path("../../app/javascript/tree_view/index.js", __dir__))
  end

  let(:javascript_package_root) do
    manifest.fetch("javascript_package_root")
  end

  it "keeps the package-root transfer drop position export aligned with the manifest" do
    positions = javascript_package_root.fetch("transfer_drop_positions")

    expect(javascript_package_root.fetch("named_exports")).to include("TreeViewTransferDropPositions")
    expect(positions).to eq({"before" => "before", "inside" => "inside", "after" => "after"})
    expect(entrypoint_source).to include("export const TreeViewTransferDropPositions = Object.freeze({")

    positions.each do |key, value|
      expect(entrypoint_source).to include("#{key}: \"#{value}\"")
    end
  end

  it "keeps the package-root transfer data attribute export aligned with the manifest" do
    attributes = javascript_package_root.fetch("transfer_data_attributes")

    expect(javascript_package_root.fetch("named_exports")).to include("TreeViewTransferDataAttributes")
    expect(attributes).to eq({
      "payload" => "data-tree-transfer-payload",
      "disabled" => "data-tree-transfer-disabled"
    })
    expect(entrypoint_source).to include("export const TreeViewTransferDataAttributes = Object.freeze({")

    attributes.each do |key, value|
      expect(entrypoint_source).to include("#{key}: \"#{value}\"")
    end
  end
end
