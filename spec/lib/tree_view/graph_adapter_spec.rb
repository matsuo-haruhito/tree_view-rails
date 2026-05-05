require "spec_helper"
GraphAdapterNode = Struct.new(:id, :children)

RSpec.describe TreeView::GraphAdapter do
  it "provides roots, children, and node_key" do
    child = GraphAdapterNode.new(2, [])
    root = GraphAdapterNode.new(1, [child])
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.roots).to eq([root])
    expect(adapter.children_for(root)).to eq([child])
    expect(adapter.node_key_for(root)).to eq(["GraphAdapterNode", 1])
  end

  it "prefers node_key_resolver when provided" do
    node = GraphAdapterNode.new(1, [])
    adapter = described_class.new(
      roots: [node],
      children_resolver: ->(candidate) { candidate.children },
      node_key_resolver: ->(candidate) { "node-#{candidate.id}" }
    )

    expect(adapter.node_key_for(node)).to eq("node-1")
  end
end
