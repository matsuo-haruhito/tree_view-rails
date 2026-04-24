require "spec_helper"

RSpec.describe TreeView::GraphAdapter do
  Node = Struct.new(:id, :children)

  it "provides roots, children, and node_key" do
    child = Node.new(2, [])
    root = Node.new(1, [child])
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.roots).to eq([root])
    expect(adapter.children_for(root)).to eq([child])
    expect(adapter.node_key_for(root)).to eq(["Node", 1])
  end

  it "prefers node_key_resolver when provided" do
    node = Node.new(1, [])
    adapter = described_class.new(
      roots: [node],
      children_resolver: ->(candidate) { candidate.children },
      node_key_resolver: ->(candidate) { "node-#{candidate.id}" }
    )

    expect(adapter.node_key_for(node)).to eq("node-1")
  end
end
