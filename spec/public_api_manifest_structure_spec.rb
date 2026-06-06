# frozen_string_literal: true

require "spec_helper"
require "psych"
require "tree_view/resource_table_render_state"
require "yaml"

PUBLIC_API_MANIFEST_STRUCTURE_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS = %w[
  module_methods
  configuration_options
  public_constants
  path_tree_builder_node_shapes
  helper_methods
  helper_option_keys
  toolbar_actions
  grouped_option_keys
  resource_table_render_state_call
  render_state_callback_builder_keys
  javascript_package_root
].freeze

RSpec.describe "Public API manifest structure" do
  def manifest_source
    @manifest_source ||= File.read(PUBLIC_API_MANIFEST_STRUCTURE_PATH)
  end

  def manifest
    @manifest ||= YAML.safe_load(manifest_source)
  end

  def duplicate_mapping_keys(yaml_source)
    document = Psych.parse(yaml_source)
    duplicates = []

    walk_yaml_node(document.root, [], duplicates)

    duplicates
  end

  def walk_yaml_node(node, path, duplicates)
    case node
    when Psych::Nodes::Mapping
      seen_keys = {}

      node.children.each_slice(2) do |key_node, value_node|
        key = key_node.value.to_s
        key_path = (path + [key]).join(".")

        duplicates << key_path if seen_keys[key]
        seen_keys[key] = true

        walk_yaml_node(value_node, path + [key], duplicates)
      end
    when Psych::Nodes::Sequence
      node.children.each_with_index do |child, index|
        walk_yaml_node(child, path + [index.to_s], duplicates)
      end
    end
  end

  it "keeps expected top-level sections explicit" do
    expect(manifest.keys).to eq(PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS)
  end

  it "does not contain duplicate keys in any mapping" do
    expect(duplicate_mapping_keys(manifest_source)).to eq([])
  end

  it "detects duplicate keys inside nested mappings" do
    yaml = <<~YAML
      javascript_package_root:
        event_names:
          state: {}
          state: {}
    YAML

    expect(duplicate_mapping_keys(yaml)).to eq(["javascript_package_root.event_names.state"])
  end

  it "keeps grouped option key sections shaped as non-empty string lists" do
    manifest.fetch("grouped_option_keys").each do |group_name, keys|
      expect(group_name).to be_a(String)
      expect(keys).to be_an(Array), "expected grouped_option_keys.#{group_name} to be an array"
      expect(keys).not_to be_empty, "expected grouped_option_keys.#{group_name} to list public keys"
      expect(keys).to all(be_a(String))
    end
  end

  it "keeps resource table render state keyword sections shaped as non-empty string lists" do
    section = manifest.fetch("resource_table_render_state_call")

    %w[required_keywords optional_keywords].each do |section_name|
      keywords = section.fetch(section_name)

      expect(keywords).to be_an(Array), "expected #{section_name} to be an array"
      expect(keywords).not_to be_empty, "expected #{section_name} to list public keywords"
      expect(keywords).to all(be_a(String))
    end
  end

  it "keeps resource table render state keyword sections synchronized with the runtime call signature" do
    section = manifest.fetch("resource_table_render_state_call")
    parameters = TreeView::ResourceTableRenderState.method(:call).parameters
    required_keywords = parameters.select { |kind, _name| kind == :keyreq }.map(&:last).map(&:to_s)
    optional_keywords = parameters.select { |kind, _name| kind == :key }.map(&:last).map(&:to_s)

    expect(section.fetch("required_keywords")).to eq(required_keywords)
    expect(section.fetch("optional_keywords")).to eq(optional_keywords)
    expect(parameters).to include([:keyrest, :render_options])
    expect(section.fetch("render_options_contract")).to eq("render_state_pass_through")
  end

  it "keeps JavaScript event names and detail keys in nested hash sections" do
    javascript_manifest = manifest.fetch("javascript_package_root")

    %w[event_names event_detail_keys].each do |section_name|
      section = javascript_manifest.fetch(section_name)

      expect(section).to be_a(Hash)
      expect(section).not_to be_empty

      section.each do |group_name, events|
        expect(group_name).to be_a(String)
        expect(events).to be_a(Hash), "expected #{section_name}.#{group_name} to map event names"
        expect(events).not_to be_empty
      end
    end
  end
end
