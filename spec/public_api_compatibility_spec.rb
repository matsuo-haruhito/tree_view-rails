# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Public API compatibility" do
  TestNode = Struct.new(:id, :parent_id, :name, keyword_init: true)

  def public_ui_config
    TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "node_button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "node_show_button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" }
    )
  end

  def public_tree
    root = TestNode.new(id: 1, parent_id: nil, name: "Root")
    child = TestNode.new(id: 2, parent_id: 1, name: "Child")

    TreeView::Tree.new(records: [root, child], parent_id_method: :parent_id)
  end

  it "keeps documented TreeView module methods available" do
    expect(TreeView).to respond_to(:configure)
    expect(TreeView).to respond_to(:configuration)
    expect(TreeView).to respond_to(:reset_configuration!)
    expect(TreeView).to respond_to(:parse_selection_params)
    expect(TreeView).to respond_to(:node_key)

    expect(TreeView.node_key(:document, 1)).to eq("document:1")
  end

  it "keeps documented public Ruby constants available" do
    %i[
      Tree
      RenderState
      VisibleRows
      RenderWindow
      UiConfig
      UiConfigBuilder
      GraphAdapter
      PathTree
      ReverseTree
      PersistedState
      StateStore
    ].each do |constant_name|
      expect(TreeView.const_defined?(constant_name)).to be(true), "expected TreeView::#{constant_name} to remain public"
    end
  end

  it "keeps documented RenderState grouped options available" do
    tree = instance_double(TreeView::Tree)
    ui_config = instance_double(TreeView::UiConfig)

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      initial_expansion: {
        default: :collapsed,
        max_depth: 2,
        expanded_keys: ["node:1"],
        collapsed_keys: ["node:2"]
      },
      render_scope: {
        max_depth: 3,
        max_leaf_distance: 1
      },
      toggle_scope: {
        max_depth_from_root: 4,
        max_leaf_distance: 2
      },
      selection: {
        enabled: true,
        visibility: :leaves,
        checkbox_name: "selected_documents[]",
        selected_keys: ["node:3"],
        cascade: true,
        indeterminate: true,
        max_count: 5
      },
      lazy_loading: {
        enabled: true,
        loaded_keys: ["node:1"],
        scope: "children"
      }
    )

    expect(state.initial_state).to eq(:collapsed)
    expect(state.max_initial_depth).to eq(2)
    expect(state.expanded_keys).to eq(["node:1"])
    expect(state.collapsed_keys).to eq(["node:2"])
    expect(state.max_render_depth).to eq(3)
    expect(state.max_leaf_distance).to eq(1)
    expect(state.max_toggle_depth_from_root).to eq(4)
    expect(state.max_toggle_leaf_distance).to eq(2)
    expect(state.selection_enabled?).to eq(true)
    expect(state.selection_visibility).to eq(:leaves)
    expect(state.selection_checkbox_name).to eq("selected_documents[]")
    expect(state.selection_selected_keys).to eq(["node:3"])
    expect(state.selection_cascade?).to eq(true)
    expect(state.selection_indeterminate?).to eq(true)
    expect(state.selection_max_count).to eq(5)
    expect(state.lazy_loading_enabled?).to eq(true)
    expect(state.lazy_loading_loaded_keys).to eq(["node:1"])
    expect(state.lazy_loading_scope).to eq("children")
  end

  it "keeps documented helper method names available through TreeViewHelper" do
    %i[
      tree_view_rows
      tree_view_window
      tree_node_dom_id
      tree_selection_value
      tree_view_breadcrumb
    ].each do |method_name|
      expect(TreeViewHelper.public_instance_methods).to include(method_name)
    end
  end

  it "keeps tree_view_rows and tree_view_window helper entrypoints callable" do
    helper_class = Class.new do
      include TreeViewHelper

      def render(partial:, collection: nil, as: nil, locals: {})
        {partial: partial, collection: collection, as: as, locals: locals}
      end
    end

    tree = public_tree
    render_state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: public_ui_config
    )
    helper = helper_class.new

    rows_result = helper.tree_view_rows(render_state)
    window = helper.tree_view_window(render_state, offset: 0, limit: 1)
    window_result = helper.tree_view_rows(render_state, window: window)

    expect(rows_result).to include(partial: "tree_view/tree_row", collection: tree.root_items, as: :item)
    expect(window).to be_a(TreeView::RenderWindow)
    expect(window.rows.length).to eq(1)
    expect(window_result).to include(partial: "tree_view/tree_window_row", as: :visible_row)
  end

  it "keeps representative public object behavior available" do
    tree = public_tree
    visible_rows = TreeView::VisibleRows.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "items/tree_columns",
        ui_config: public_ui_config
      )
    )
    render_window = TreeView::RenderWindow.new(visible_rows, offset: 0, limit: 1)
    persisted_state = TreeView::PersistedState.new(tree_instance_key: "documents#index", expanded_keys: ["node:1"])

    expect(tree.root_items.map(&:id)).to eq([1])
    expect(visible_rows.to_a.first).to be_a(TreeView::VisibleRows::Row)
    expect(render_window.rows.length).to eq(1)
    expect(render_window.total_count).to eq(2)
    expect(persisted_state.tree_instance_key).to eq("documents#index")
    expect(persisted_state.expanded_keys).to eq(["node:1"])
  end
end
