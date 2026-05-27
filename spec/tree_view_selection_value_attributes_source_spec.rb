# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_API_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
JAVASCRIPT_ENTRYPOINT_PATH = File.expand_path("../app/javascript/tree_view/index.js", __dir__)

RSpec.describe "TreeViewSelectionValueAttributes source compatibility" do
  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(PUBLIC_API_MANIFEST_PATH)
  end

  def documented_selection_value_attributes
    public_api_manifest.fetch("javascript_package_root").fetch("selection_value_attributes")
  end

  def javascript_entrypoint_source
    @javascript_entrypoint_source ||= File.read(JAVASCRIPT_ENTRYPOINT_PATH)
  end

  def camelize_manifest_key(key)
    head, *tail = key.split("_")
    ([head] + tail.map(&:capitalize)).join
  end

  it "keeps documented selection value attributes available through TreeViewSelectionValueAttributes" do
    source = javascript_entrypoint_source

    expect(source).to include("export const TreeViewSelectionValueAttributes = Object.freeze(")

    documented_selection_value_attributes.each do |manifest_key, attribute_name|
      camelized_key = camelize_manifest_key(manifest_key)

      expect(source).to include("#{camelized_key}: \"#{attribute_name}\""),
        "expected TreeViewSelectionValueAttributes.#{camelized_key} to remain mapped to #{attribute_name}"
    end
  end
end
