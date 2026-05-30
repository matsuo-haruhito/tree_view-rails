# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "TreeView transfer drop position export" do
  let(:manifest) do
    YAML.safe_load_file(File.expand_path("../../config/public_api_manifest.yml", __dir__))
  end

  let(:entrypoint_source) do
    File.read(File.expand_path("../../app/javascript/tree_view/index.js", __dir__))
  end

  it "keeps the package-root transfer drop position export aligned with the manifest" do
    positions = manifest.fetch("javascript_package_root").fetch("transfer_drop_positions")

    expect(manifest.fetch("javascript_package_root").fetch("named_exports")).to include("TreeViewTransferDropPositions")
    expect(positions).to eq({"before" => "before", "inside" => "inside", "after" => "after"})
    expect(entrypoint_source).to include("export const TreeViewTransferDropPositions = Object.freeze({")

    positions.each do |key, value|
      expect(entrypoint_source).to include("#{key}: \"#{value}\"")
    end
  end
end
