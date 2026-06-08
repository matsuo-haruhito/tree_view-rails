# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Public API integration hooks" do
  def manifest_path
    File.expand_path("../config/public_api_manifest.yml", __dir__)
  end

  def entrypoint_path
    File.expand_path("../app/javascript/tree_view/index.js", __dir__)
  end

  def javascript_manifest
    YAML.safe_load_file(manifest_path).fetch("javascript_package_root")
  end

  def integration_hooks
    javascript_manifest.fetch("integration_hooks")
  end

  def entrypoint_source
    @entrypoint_source ||= File.read(entrypoint_path)
  end

  def camelize_key(value)
    value.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }
  end

  it "keeps documented integration hooks available through TreeViewIntegrationHooks" do
    expect(entrypoint_source).to include("export const TreeViewIntegrationHooks = Object.freeze({")

    integration_hooks.each do |group_name, hooks|
      exported_group_name = camelize_key(group_name)

      expect(entrypoint_source).to include("#{exported_group_name}: Object.freeze({")

      hooks.each do |hook_key, hook_name|
        exported_hook_key = camelize_key(hook_key)

        expect(entrypoint_source).to include("#{exported_hook_key}: \"#{hook_name}\"")
      end
    end
  end

  it "does not fold selection host-element value hooks into the general integration hook export" do
    selection_hooks = javascript_manifest.fetch("selection_data_hooks").values
    general_hooks = integration_hooks.values.flat_map(&:values)

    expect(general_hooks & selection_hooks).to eq([])
  end
end
