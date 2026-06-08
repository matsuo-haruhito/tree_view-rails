# frozen_string_literal: true

require "spec_helper"
require "yaml"

UI_CONFIG_BUILDER_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)

RSpec.describe "UiConfigBuilder public API manifest" do
  def manifest_option_keys
    YAML.safe_load_file(UI_CONFIG_BUILDER_MANIFEST_PATH).fetch("ui_config_builder_option_keys")
  end

  def keyword_option_keys(method_name)
    TreeView::UiConfigBuilder.instance_method(method_name).parameters.filter_map do |parameter_type, parameter_name|
      parameter_name.to_s if %i[key keyreq].include?(parameter_type)
    end
  end

  it "keeps build and build_turbo keyword surfaces aligned" do
    expected_keys = %w[
      show_descendants_path_builder
      hide_descendants_path_builder
      toggle_all_path_builder
      load_children_path_builder
      turbo_frame
      indent_unit
      scope_format
    ]

    expect(manifest_option_keys.fetch("build")).to eq(expected_keys)
    expect(manifest_option_keys.fetch("build_turbo")).to eq(expected_keys)
    expect(keyword_option_keys(:build)).to eq(expected_keys)
    expect(keyword_option_keys(:build_turbo)).to eq(expected_keys)
  end

  it "keeps static and client-side builders on the narrow indent option surface" do
    expected_keys = %w[indent_unit]

    expect(manifest_option_keys.fetch("build_static")).to eq(expected_keys)
    expect(manifest_option_keys.fetch("build_client_side")).to eq(expected_keys)
    expect(keyword_option_keys(:build_static)).to eq(expected_keys)
    expect(keyword_option_keys(:build_client_side)).to eq(expected_keys)
  end
end
