# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Public API manifest guard parity" do
  NESTED_PUBLIC_API_MANIFEST_KEY_LISTS = {
    "ui_config_builder_option_keys" => {
      node_const: "requiredUiConfigBuilderOptionKeys",
      expected_keys: %w[
        build
        build_turbo
        build_static
        build_client_side
      ]
    },
    "helper_option_keys" => {
      node_const: "requiredHelperOptionKeys",
      expected_keys: %w[
        tree_view_rows
        tree_view_window
        tree_view_breadcrumb
        tree_view_toolbar
      ]
    },
    "grouped_option_keys" => {
      node_const: "requiredGroupedOptionKeys",
      expected_keys: %w[
        initial_expansion
        render_scope
        toggle_scope
        toggle_icons
        selection
        lazy_loading
        row_status
      ]
    },
    "javascript_package_root.integration_hooks" => {
      node_const: "requiredIntegrationHookKeys",
      expected_keys: %w[
        state
        remote_state
        transfer
      ]
    }
  }.freeze

  let(:manifest_structure_spec_path) { File.expand_path("public_api_manifest_structure_spec.rb", __dir__) }
  let(:manifest_structure_smoke_path) { File.expand_path("../script/test_public_api_manifest_structure.mjs", __dir__) }

  def ruby_expected_top_level_keys
    source = File.read(manifest_structure_spec_path)
    match = source.match(/PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS = %w\[\n(?<keys>.*?)\n\]\.freeze/m)

    raise "Could not find PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS literal in #{manifest_structure_spec_path}" unless match

    match[:keys].lines.map(&:strip).reject(&:empty?)
  end

  def node_expected_top_level_keys
    source = File.read(manifest_structure_smoke_path)
    match = source.match(/const expectedKeys = \[\n(?<keys>.*?)\n  \]/m)

    raise "Could not find assertTopLevelKeys expectedKeys literal in #{manifest_structure_smoke_path}" unless match

    match[:keys].scan(/"([^"]+)"/).flatten
  end

  def node_expected_nested_keys(const_name)
    source = File.read(manifest_structure_smoke_path)
    match = source.match(/const #{Regexp.escape(const_name)} = \[\n(?<keys>.*?)\n\]/m)

    raise "Could not find #{const_name} literal in #{manifest_structure_smoke_path}" unless match

    match[:keys].scan(/"([^"]+)"/).flatten
  end

  it "keeps Ruby and Node manifest top-level section guards synchronized" do
    ruby_keys = ruby_expected_top_level_keys
    node_keys = node_expected_top_level_keys

    expect(node_keys).to eq(ruby_keys), <<~MESSAGE
      expected script/test_public_api_manifest_structure.mjs assertTopLevelKeys expectedKeys
      to match spec/public_api_manifest_structure_spec.rb PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS.
      missing from Node smoke: #{(ruby_keys - node_keys).inspect}
      extra in Node smoke: #{(node_keys - ruby_keys).inspect}
    MESSAGE
  end

  it "keeps representative nested manifest key guards synchronized" do
    NESTED_PUBLIC_API_MANIFEST_KEY_LISTS.each do |manifest_path, config|
      ruby_keys = config.fetch(:expected_keys)
      node_keys = node_expected_nested_keys(config.fetch(:node_const))

      expect(node_keys).to eq(ruby_keys), <<~MESSAGE
        expected script/test_public_api_manifest_structure.mjs #{config.fetch(:node_const)}
        to match the Ruby expected keys for config/public_api_manifest.yml##{manifest_path}.
        missing from Node smoke: #{(ruby_keys - node_keys).inspect}
        extra in Node smoke: #{(node_keys - ruby_keys).inspect}
      MESSAGE
    end
  end
end
