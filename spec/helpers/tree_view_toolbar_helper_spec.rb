# frozen_string_literal: true

require "spec_helper"
require "action_view"
require "action_view/helpers"

RSpec.describe "tree_view_toolbar helper" do
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
  let(:render_state) do
    instance_double(TreeView::RenderState, ui_config: ui_config)
  end

  it "returns the supported toolbar actions through a public helper" do
    actions = helper.tree_view_toolbar_supported_actions

    expect(actions).to eq(%i[expand_all collapse_all collapse_all_except_current_path])

    actions << :custom_action

    expect(helper.tree_view_toolbar_supported_actions).to eq(%i[expand_all collapse_all collapse_all_except_current_path])
  end

  around do |example|
    original_available_locales = I18n.available_locales
    I18n.available_locales = original_available_locales | %i[toolbar_test_ja toolbar_test_missing]
    example.run
  ensure
    I18n.available_locales = original_available_locales
  end

  it "returns toolbar action metadata for host-app-owned controls" do
    actions = helper.tree_view_toolbar_actions(render_state, actions: [:expand_all, :collapse_all], labels: {expand_all: "Open all"})

    expect(actions).to eq(
      [
        {
          action: :expand_all,
          state: :expanded,
          label: "Open all",
          path: "/tree?state=expanded",
          disabled: false,
          data: {tree_view_toolbar_action: :expand_all}
        },
        {
          action: :collapse_all,
          state: :collapsed,
          label: "Collapse all",
          path: "/tree?state=collapsed",
          disabled: false,
          data: {tree_view_toolbar_action: :collapse_all}
        }
      ]
    )
  end

  it "uses I18n toolbar labels when a translation is available" do
    I18n.backend.store_translations(:toolbar_test_ja, {
      tree_view: {
        toolbar: {
          labels: {
            expand_all: "すべて展開"
          }
        }
      }
    })

    action = I18n.with_locale(:toolbar_test_ja) do
      helper.tree_view_toolbar_action_metadata(render_state, :expand_all)
    end

    expect(action[:label]).to eq("すべて展開")
  end

  it "prefers an explicit label override over the I18n default" do
    I18n.backend.store_translations(:toolbar_test_ja, {
      tree_view: {
        toolbar: {
          labels: {
            expand_all: "すべて展開"
          }
        }
      }
    })

    actions = I18n.with_locale(:toolbar_test_ja) do
      helper.tree_view_toolbar_actions(render_state, actions: [:expand_all], labels: {expand_all: "Open all now"})
    end

    expect(actions.first[:label]).to eq("Open all now")
  end

  it "falls back to the built-in English label when no translation exists" do
    action = I18n.with_locale(:toolbar_test_missing) do
      helper.tree_view_toolbar_action_metadata(render_state, :collapse_all_except_current_path)
    end

    expect(action[:label]).to eq("Collapse all except current path")
  end

  it "returns disabled metadata when the ui does not expose toggle_all_path" do
    static_ui_config = TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_button_#{item_or_id}" }
    )
    static_render_state = instance_double(TreeView::RenderState, ui_config: static_ui_config)

    action = helper.tree_view_toolbar_action_metadata(static_render_state, :expand_all)

    expect(action).to eq(
      action: :expand_all,
      state: :expanded,
      label: "Expand all",
      path: nil,
      disabled: true,
      data: {tree_view_toolbar_action: :expand_all, tree_view_toolbar_disabled: true}
    )
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

  it "rejects unknown metadata actions" do
    expect do
      helper.tree_view_toolbar_action_metadata(render_state, :unknown)
    end.to raise_error(TreeView::ConfigurationError, /unknown tree_view_toolbar action/)
  end
end
