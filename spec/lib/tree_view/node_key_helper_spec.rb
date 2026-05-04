require "spec_helper"

RSpec.describe "TreeView node key helper" do
  it "builds a namespaced node key" do
    expect(TreeView.node_key("Document", 123)).to eq("Document:123")
  end

  it "normalizes whitespace" do
    expect(TreeView.node_key(" Document ", " 123 ")).to eq("Document:123")
  end

  it "can be used as a node key resolver" do
    item = Struct.new(:id).new(1)
    tree = TreeView::Tree.new(
      records: [item],
      parent_id_method: :parent_id,
      node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
    )

    expect(tree.node_key_for(item)).to eq("Struct:1")
  end
end
