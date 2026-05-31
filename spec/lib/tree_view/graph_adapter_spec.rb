require "spec_helper"
GraphAdapterNode = Struct.new(:id, :children)
GraphAdapterSingleChild = Struct.new(:id)

RSpec.describe TreeView::GraphAdapter do
  it "provides roots, children, and node_key" do
    child = GraphAdapterNode.new(2, [])
    root = GraphAdapterNode.new(1, [child])
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.roots).to eq([root])
    expect(adapter.children_for(root)).to eq([child])
    expect(adapter.node_key_for(root)).to eq(["GraphAdapterNode", 1])
  end

  it "normalizes a nil children result to an empty array" do
    root = GraphAdapterNode.new(1, nil)
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.children_for(root)).to eq([])
  end

  it "wraps a single child object in an array" do
    child = GraphAdapterSingleChild.new(2)
    root = GraphAdapterNode.new(1, child)
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.children_for(root)).to eq([child])
  end

  it "preserves array-like enumerable children results" do
    first_child = GraphAdapterNode.new(2, [])
    second_child = GraphAdapterNode.new(3, [])
    relation_like_children = Class.new do
      def initialize(children)
        @children = children
      end

      def to_a
        @children
      end
    end.new([first_child, second_child])
    root = GraphAdapterNode.new(1, relation_like_children)
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.children_for(root)).to eq([first_child, second_child])
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
