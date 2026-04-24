require 'rails_helper'

RSpec.describe TreeView::GraphAdapter do
  Node = Struct.new(:id, :children)

  it 'roots/children/node_key を提供できる' do
    child = Node.new(2, [])
    root = Node.new(1, [child])
    adapter = described_class.new(roots: [root], children_resolver: ->(node) { node.children })

    expect(adapter.roots).to eq([root])
    expect(adapter.children_for(root)).to eq([child])
    expect(adapter.node_key_for(root)).to eq(['Node', 1])
  end

  it 'node_key_resolver があればそちらを優先する' do
    node = Node.new(1, [])
    adapter = described_class.new(
      roots: [node],
      children_resolver: ->(n) { n.children },
      node_key_resolver: ->(n) { "node-#{n.id}" }
    )

    expect(adapter.node_key_for(node)).to eq('node-1')
  end
end
