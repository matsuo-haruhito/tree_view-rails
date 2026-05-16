# frozen_string_literal: true

require "spec_helper"
require "action_view"
require "action_view/helpers"

RSpec.describe "tree_view_toolbar helper" do
  let(:helper_class) do
    Class.new do
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
  let(:render_state) do
    instance_double(TreeView::RenderState, ui_config: ui_config)
  end

  it "renders expand and collapse links by default" do
    html = helper.tree_view_toolbar(render_state)

    expect(html).to include("tree-view-toolbar")
    expect(html).to include("href=\"/tree?state=expanded\"")
    expect(html).to include("Expand all")
    expect(html).to include("href=\"/tree?state=collapsed\"")
    expect(html).to include("Collapse all")
  end

  it "renders collapse current path action" do
    html = helper.tree_view_toolbar(render_state, actions: [:collapse_all_except_current_path])

    expect(html).to include("href=\"/tree?state=current_path\"")
    expect(html).to include("Collapse all except current path")
  end

  it "supports custom labels and class names" do
    html = helper.tree_view_toolbar(
      render_state,
      actions: [:expand_all],
      labels: {expand_all: "Open all"},
      class_name: "custom-toolbar",
      button_class_name: "custom-button"
    )

    expect(html).to include("custom-toolbar")
    expect(html).to include("custom-button")
    expect(html).to include("Open all")
  end

  it "renders disabled buttons when no toggle_all_path is configured" do
    static_ui_config = TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_button_#{item_or_id}" }
    )
    static_render_state = instance_double(TreeView::RenderState, ui_config: static_ui_config)

    html = helper.tree_view_toolbar(static_render_state, actions: [:expand_all])

    expect(html).to include("disabled=\"disabled\"")
    expect(html).to include("data-tree-view-toolbar-disabled=\"true\"")
  end

  it "rejects unknown actions" do
    expect do
      helper.tree_view_toolbar(render_state, actions: [:unknown])
    end.to raise_error(TreeView::ConfigurationError, /unknown tree_view_toolbar action/)
  end
end
