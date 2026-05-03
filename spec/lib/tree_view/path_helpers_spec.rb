require "spec_helper"

RSpec.describe "TreeView::Tree parent path helpers" do
  PathNode = Struct.new(:id, :parent_item_id, :name, keyword_init: true)
  PathCountry = Struct.new(:id, :name, :children)

  def build_tree(records)
    TreeView::Tree.new(records: records, parent_id_method: :parent_item_id)
  end

  it "returns the parent record" do
    root = PathNode.new(id: 1, parent_item_id: nil, name: "root")
    child = PathNode.new(id: 2, parent_item_id: 1, name: "child")
    tree = build_tree([root, child])

    expect(tree.parent_for(child)).to eq(root)
    expect(tree.parent_for(root)).to be_nil
  end

  it "returns nil when the parent is missing from records" do
    orphan = PathNode.new(id: 2, parent_item_id: 999, name: "orphan")
    tree = build_tree([orphan])

    expect(tree.parent_for(orphan)).to be_nil
    expect(tree.ancestors_for(orphan)).to eq([])
    expect(tree.path_for(orphan)).to eq([orphan])
  end

  it "returns ancestors from root to parent" do
    root = PathNode.new(id: 1, parent_item_id: nil, name: "root")
    parent = PathNode.new(id: 2, parent_item_id: 1, name: "parent")
    child = PathNode.new(id: 3, parent_item_id: 2, name: "child")
    tree = build_tree([root, parent, child])

    expect(tree.ancestors_for(child)).to eq([root, parent])
  end

  it "returns a path from root to item" do
    root = PathNode.new(id: 1, parent_item_id: nil, name: "root")
    parent = PathNode.new(id: 2, parent_item_id: 1, name: "parent")
    child = PathNode.new(id: 3, parent_item_id: 2, name: "child")
    tree = build_tree([root, parent, child])

    expect(tree.path_for(child)).to eq([root, parent, child])
  end

  it "returns paths for multiple items" do
    root = PathNode.new(id: 1, parent_item_id: nil, name: "root")
    child_a = PathNode.new(id: 2, parent_item_id: 1, name: "child-a")
    child_b = PathNode.new(id: 3, parent_item_id: 1, name: "child-b")
    tree = build_tree([root, child_a, child_b])

    expect(tree.paths_for([child_a, child_b])).to eq([[root, child_a], [root, child_b]])
  end

  it "detects cycles while walking parent paths" do
    node_a = PathNode.new(id: 1, parent_item_id: 2, name: "a")
    node_b = PathNode.new(id: 2, parent_item_id: 1, name: "b")
    tree = build_tree([node_a, node_b])

    expect do
      tree.path_for(node_a)
    end.to raise_error(ArgumentError, /cycle detected in parent path/)
  end

  it "rejects parent path helpers in resolver mode" do
    country = PathCountry.new(1, "japan", [])
    tree = TreeView::Tree.new(
      roots: [country],
      children_resolver: ->(node) { node.children }
    )

    expect do
      tree.parent_for(country)
    end.to raise_error(ArgumentError, /only supported in records mode/)
  end
end
