require "spec_helper"

RSpec.describe "TreeView row status builders" do
  RowStatusNode = Struct.new(:id, :parent_item_id, :name, :disabled, :readonly, keyword_init: true)

  let(:tree) do
    nodes = [
      RowStatusNode.new(id: 1, parent_item_id: nil, name: "root", disabled: true, readonly: false),
      RowStatusNode.new(id: 2, parent_item_id: 1, name: "child", disabled: false, readonly: true)
    ]
    TreeView::Tree.new(records: nodes, parent_id_method: :parent_item_id)
  end

  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "adds disabled and readonly row classes" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      row_class_builder: ->(item) { "host-#{item.name}" },
      row_disabled_builder: ->(item) { item.disabled },
      row_readonly_builder: ->(item) { item.readonly }
    )

    root, child = tree.root_items.first, tree.children_for(tree.root_items.first).first

    expect(state.row_class_builder.call(root)).to include("host-root", "tree-view-row--disabled")
    expect(state.row_class_builder.call(child)).to include("host-child", "tree-view-row--readonly")
  end

  it "adds disabled and readonly row data" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      row_data_builder: ->(item) { { name: item.name } },
      row_disabled_builder: ->(item) { item.disabled },
      row_readonly_builder: ->(item) { item.readonly },
      row_disabled_reason_builder: ->(item) { item.disabled ? "archived" : nil }
    )

    root, child = tree.root_items.first, tree.children_for(tree.root_items.first).first

    expect(state.row_data_builder.call(root)).to include(
      name: "root",
      tree_view_row_disabled: true,
      tree_view_row_disabled_reason: "archived"
    )
    expect(state.row_data_builder.call(child)).to include(
      name: "child",
      tree_view_row_readonly: true
    )
  end

  it "rejects invalid row status builders" do
    expect do
      TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        row_disabled_builder: :invalid
      )
    end.to raise_error(ArgumentError, /row_disabled_builder/)
  end

  it "preserves row data builder validation" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      row_data_builder: ->(_item) { :invalid },
      row_disabled_builder: ->(_item) { false }
    )

    expect do
      state.row_data_builder.call(tree.root_items.first)
    end.to raise_error(ArgumentError, /row_data_builder must return a Hash-like object/)
  end
end
