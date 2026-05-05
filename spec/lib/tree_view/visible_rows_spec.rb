require "spec_helper"
VisibleRowsNode = Struct.new(:id, :parent_item_id, :name, keyword_init: true)

RSpec.describe TreeView::VisibleRows do
  let(:root) { VisibleRowsNode.new(id: 1, parent_item_id: nil, name: "root") }
  let(:child) { VisibleRowsNode.new(id: 2, parent_item_id: 1, name: "child") }
  let(:grandchild) { VisibleRowsNode.new(id: 3, parent_item_id: 2, name: "grandchild") }
  let(:sibling) { VisibleRowsNode.new(id: 4, parent_item_id: 1, name: "sibling") }
  let(:nodes) { [root, child, grandchild, sibling] }
  let(:tree) { TreeView::Tree.new(records: nodes, parent_id_method: :parent_item_id, sorter: ->(items, _tree) { items.sort_by(&:id) }) }
  let(:ui_config) { TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "node").build_static }

  def build_render_state(**options)
    TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      **options
    )
  end

  it "flattens visible rows with depth and parent information" do
    rows = described_class.new(tree: tree, root_items: tree.root_items, render_state: build_render_state).to_a

    expect(rows.map(&:node_key)).to eq([1, 2, 3, 4])
    expect(rows.map(&:depth)).to eq([0, 1, 2, 1])
    expect(rows.map(&:parent_key)).to eq([nil, 1, 2, 1])
    expect(rows.map(&:has_children?)).to eq([true, true, false, false])
    expect(rows.map(&:expanded?)).to eq([true, true, false, false])
  end

  it "respects collapsed initial state" do
    rows = described_class.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: build_render_state(initial_state: :collapsed)
    ).to_a

    expect(rows.map(&:node_key)).to eq([1])
    expect(rows.first.expanded?).to eq(false)
  end

  it "respects explicit expanded keys inside a collapsed tree" do
    rows = described_class.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: build_render_state(initial_state: :collapsed, expanded_keys: [1, 2])
    ).to_a

    expect(rows.map(&:node_key)).to eq([1, 2, 3, 4])
    expect(rows.find { |row| row.node_key == 1 }.expanded?).to eq(true)
    expect(rows.find { |row| row.node_key == 2 }.expanded?).to eq(true)
  end

  it "respects collapsed keys inside an expanded tree" do
    rows = described_class.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: build_render_state(initial_state: :expanded, collapsed_keys: [2])
    ).to_a

    expect(rows.map(&:node_key)).to eq([1, 2, 4])
    expect(rows.find { |row| row.node_key == 1 }.expanded?).to eq(true)
    expect(rows.find { |row| row.node_key == 2 }.expanded?).to eq(false)
    expect(rows.find { |row| row.node_key == 4 }.parent_key).to eq(1)
  end

  it "preserves sorted sibling order for wide trees" do
    extra_sibling = VisibleRowsNode.new(id: 5, parent_item_id: 1, name: "extra sibling")
    wide_tree = TreeView::Tree.new(
      records: nodes + [extra_sibling],
      parent_id_method: :parent_item_id,
      sorter: ->(items, _tree) { items.sort_by { |item| -item.id } }
    )
    wide_render_state = TreeView::RenderState.new(
      tree: wide_tree,
      root_items: wide_tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: ui_config
    )

    rows = described_class.new(tree: wide_tree, root_items: wide_tree.root_items, render_state: wide_render_state).to_a

    expect(rows.map(&:node_key)).to eq([1, 5, 4, 2, 3])
    expect(rows.select { |row| row.parent_key == 1 }.map(&:node_key)).to eq([5, 4, 2])
  end

  it "respects max_render_depth" do
    rows = described_class.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: build_render_state(max_render_depth: 1)
    ).to_a

    expect(rows.map(&:node_key)).to eq([1, 2, 4])
  end

  it "respects max_leaf_distance" do
    rows = described_class.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: build_render_state(max_leaf_distance: 1)
    ).to_a

    expect(rows.map(&:node_key)).to eq([1, 2, 3, 4])
    expect(rows.map(&:depth)).to eq([0, 1, 2, 1])
  end

  it "respects max_initial_depth when deciding expanded rows" do
    rows = described_class.new(
      tree: tree,
      root_items: tree.root_items,
      render_state: build_render_state(max_initial_depth: 1)
    ).to_a

    expect(rows.map(&:node_key)).to eq([1, 2, 4])
    expect(rows.find { |row| row.node_key == 1 }.expanded?).to eq(true)
    expect(rows.find { |row| row.node_key == 2 }.expanded?).to eq(false)
  end
end
