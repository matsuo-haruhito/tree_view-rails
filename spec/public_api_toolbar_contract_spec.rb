# frozen_string_literal: true

require "spec_helper"
require "action_view"
require "action_view/helpers"
require "yaml"

RSpec.describe "Toolbar public API contract" do
  let(:manifest) do
    YAML.safe_load_file(File.expand_path("../config/public_api_manifest.yml", __dir__)).fetch("toolbar_actions")
  end
  let(:helper_class) do
    Class.new do
      include ActionView::Context
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::FormTagHelper
      include TreeViewHelper
    end
  end
  let(:helper) { helper_class.new }
  let(:ui_config) do
    TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_button_#{item_or_id}" },
      toggle_all_path_builder: ->(state) { "/tree?state=#{state}" }
    )
  end
  let(:render_state) { instance_double(TreeView::RenderState, ui_config: ui_config) }

  it "keeps supported toolbar actions aligned with the manifest" do
    expect(helper.tree_view_toolbar_supported_actions.map(&:to_s)).to eq(manifest.keys)
  end

  it "keeps toolbar action states and action data aligned with the manifest" do
    manifest.each do |action_name, state_name|
      metadata = helper.tree_view_toolbar_action_metadata(render_state, action_name)

      expect(metadata.fetch(:action).to_s).to eq(action_name)
      expect(metadata.fetch(:state).to_s).to eq(state_name)
      expect(metadata.fetch(:data).fetch(:tree_view_toolbar_action).to_s).to eq(action_name)
      expect(metadata.fetch(:data)).not_to have_key(:tree_view_toolbar_disabled)
    end
  end

  it "keeps disabled toolbar data hooks available for custom toolbar markup" do
    static_ui_config = TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_button_#{item_or_id}" }
    )
    static_render_state = instance_double(TreeView::RenderState, ui_config: static_ui_config)

    metadata = helper.tree_view_toolbar_action_metadata(static_render_state, :expand_all)

    expect(metadata.fetch(:data)).to include(
      tree_view_toolbar_action: :expand_all,
      tree_view_toolbar_disabled: true
    )
  end
end
