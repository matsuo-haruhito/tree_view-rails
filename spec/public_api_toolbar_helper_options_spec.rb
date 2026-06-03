# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_API_TOOLBAR_HELPER_OPTIONS_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
EXPECTED_TREE_VIEW_TOOLBAR_OPTION_KEYS = %w[
  actions
  labels
  class_name
  button_class_name
  html
  action_html
].freeze

RSpec.describe "Toolbar helper option public contract" do
  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(PUBLIC_API_TOOLBAR_HELPER_OPTIONS_MANIFEST_PATH)
  end

  def tree_view_toolbar_keyword_options
    TreeViewHelper::Toolbar
      .instance_method(:tree_view_toolbar)
      .parameters
      .filter_map do |kind, name|
        case kind
        when :key, :keyreq
          name.to_s
        end
      end
  end

  it "keeps tree_view_toolbar keyword options in the public API manifest" do
    manifest_option_keys = public_api_manifest.fetch("helper_option_keys").fetch("tree_view_toolbar")

    expect(manifest_option_keys).to eq(EXPECTED_TREE_VIEW_TOOLBAR_OPTION_KEYS)
    expect(manifest_option_keys).to eq(tree_view_toolbar_keyword_options)
  end

  it "keeps helper option keys separate from toolbar action state mapping" do
    expect(public_api_manifest.fetch("toolbar_actions")).to eq({
      "expand_all" => "expanded",
      "collapse_all" => "collapsed",
      "collapse_all_except_current_path" => "current_path"
    })

    expect(public_api_manifest.fetch("helper_option_keys").fetch("tree_view_toolbar")).not_to include("expand_all")
    expect(public_api_manifest.fetch("helper_option_keys").fetch("tree_view_toolbar")).not_to include("collapse_all")
    expect(public_api_manifest.fetch("helper_option_keys").fetch("tree_view_toolbar")).not_to include("collapse_all_except_current_path")
  end
end
