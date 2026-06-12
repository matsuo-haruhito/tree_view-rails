# frozen_string_literal: true

require "spec_helper"

RSpec.describe "VisibleRows and RenderWindow generation boundaries" do
  Node = Struct.new(:id, :parent_id, :label, keyword_init: true)

  def build_tree(records)
    TreeView::Tree.new(
      records: records,
      parent_id_method: :parent_id,
      id_method: :id,
      sorter: ->(items, _tree) { items.sort_by(&:id) }
    )
  end

  def render_state_for(tree, root_items, **options)
    TreeView::RenderState.new(
      tree: tree,
      root_items: root_items,
      row_partial: "tree_view/tree_row",
      ui_config: nil,
      **options
    )
  end

  def visible_rows_for(records, **options)
    tree = build_tree(records)
    root_items = tree.root_items
    render_state = render_state_for(tree, root_items, **options)

    TreeView::VisibleRows.new(tree: tree, root_items: root_items, render_state: render_state).to_a
  end

  it "keeps deep tree depth and parent keys readable when a hidden descendant branch is collapsed" do
    records = [
      Node.new(id: "root", parent_id: nil, label: "Root"),
      Node.new(id: "a", parent_id: "root", label: "A"),
      Node.new(id: "a-1", parent_id: "a", label: "A.1"),
      Node.new(id: "a-1-1", parent_id: "a-1", label: "A.1.1"),
      Node.new(id: "a-2", parent_id: "a", label: "A.2"),
      Node.new(id: "b", parent_id: "root", label: "B")
    ]

    rows = visible_rows_for(records, collapsed_keys: ["a-1"])

    expect(rows.map { |row| [row.node_key, row.parent_key, row.depth, row.expanded?] }).to eq([
      ["root", nil, 0, true],
      ["a", "root", 1, true],
      ["a-1", "a", 2, false],
      ["a-2", "a", 2, false],
      ["b", "root", 1, false]
    ])
  end

  it "keeps wide tree ordering and render-window counts stable at an interior boundary" do
    records = [
      Node.new(id: "root", parent_id: nil, label: "Root"),
      Node.new(id: "child-1", parent_id: "root", label: "Child 1"),
      Node.new(id: "child-2", parent_id: "root", label: "Child 2"),
      Node.new(id: "child-3", parent_id: "root", label: "Child 3"),
      Node.new(id: "child-4", parent_id: "root", label: "Child 4"),
      Node.new(id: "child-5", parent_id: "root", label: "Child 5")
    ]

    visible_rows = visible_rows_for(records)
    window = TreeView::RenderWindow.new(visible_rows, offset: 2, limit: 2)

    expect(visible_rows.map(&:node_key)).to eq(%w[root child-1 child-2 child-3 child-4 child-5])
    expect(window.rows.map(&:node_key)).to eq(%w[child-2 child-3])
    expect(window.total_count).to eq(6)
    expect(window.before_count).to eq(2)
    expect(window.after_count).to eq(2)
    expect(window.start_index).to eq(2)
    expect(window.end_index).to eq(4)
    expect(window.previous_offset).to eq(0)
    expect(window.next_offset).to eq(4)
  end

  it "keeps empty out-of-range render windows explainable" do
    records = [
      Node.new(id: "root", parent_id: nil, label: "Root"),
      Node.new(id: "child", parent_id: "root", label: "Child")
    ]

    visible_rows = visible_rows_for(records)
    window = TreeView::RenderWindow.new(visible_rows, offset: 5, limit: 3)

    expect(window.rows).to eq([])
    expect(window.total_count).to eq(2)
    expect(window.before_count).to eq(2)
    expect(window.after_count).to eq(0)
    expect(window.start_index).to eq(2)
    expect(window.end_index).to eq(0)
    expect(window.previous_offset).to eq(2)
    expect(window.next_offset).to be_nil
  end
end
