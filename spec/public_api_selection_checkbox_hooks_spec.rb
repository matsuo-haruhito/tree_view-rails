# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "selection checkbox public hooks" do
  let(:manifest) do
    YAML.safe_load_file(File.expand_path("../config/public_api_manifest.yml", __dir__))
  end

  let(:javascript_entrypoint_source) do
    File.read(File.expand_path("../app/javascript/tree_view/index.js", __dir__))
  end

  let(:selection_cell_source) do
    File.read(File.expand_path("../app/views/tree_view/_tree_selection_cell.html.erb", __dir__))
  end

  let(:checkbox_hooks) do
    manifest.fetch("javascript_package_root").fetch("selection_checkbox_hooks")
  end

  it "keeps the checkbox hook export listed as a package-root public surface" do
    expect(manifest.fetch("javascript_package_root").fetch("named_exports")).to include("TreeViewSelectionCheckboxHooks")
    expect(javascript_entrypoint_source).to include("export const TreeViewSelectionCheckboxHooks = Object.freeze({")
  end

  it "keeps the checkbox class aligned with the rendered selection cell" do
    checkbox_class = checkbox_hooks.fetch("checkbox_class")

    expect(javascript_entrypoint_source).to include("checkboxClass: \"#{checkbox_class}\"")
    expect(selection_cell_source).to include("class: \"#{checkbox_class}\"")
  end

  it "keeps the disabled reason attribute aligned with the rendered selection cell" do
    disabled_reason_attribute = checkbox_hooks.fetch("disabled_reason_attribute")

    expect(javascript_entrypoint_source).to include("disabledReasonAttribute: \"#{disabled_reason_attribute}\"")
    expect(disabled_reason_attribute).to eq("data-tree-selection-disabled-reason")
    expect(selection_cell_source).to include("tree_selection_disabled_reason")
  end
end
