require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '.descendant_counts' do
    it 'returns descendant size for each node in the tree' do
      root = create(:item, name: 'root')
      child1 = create(:item, parent_item_id: root.id.to_s, name: 'child1')
      child2 = create(:item, parent_item_id: root.id.to_s, name: 'child2')
      grandchild = create(:item, parent_item_id: child1.id.to_s, name: 'grandchild')

      items_by_parent_id = Item.all.group_by(&:parent_item_id)

      counts = described_class.descendant_counts(items_by_parent_id)

      expect(counts[root.id]).to eq(3)
      expect(counts[child1.id]).to eq(1)
      expect(counts[child2.id]).to eq(0)
      expect(counts[grandchild.id]).to eq(0)
    end
  end

  describe '.child_ids_by_parent_id' do
    it 'builds parent to child id map in one pass' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id.to_s, name: 'child')

      map = described_class.child_ids_by_parent_id

      expect(map[nil]).to include(root.id)
      expect(map[root.id.to_s]).to include(child.id)
    end
  end

  describe '#descendant_ids' do
    it 'returns all descendant ids recursively' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id.to_s, name: 'child')
      grandchild = create(:item, parent_item_id: child.id.to_s, name: 'grandchild')

      expect(root.descendant_ids).to contain_exactly(child.id, grandchild.id)
      expect(child.descendant_ids).to contain_exactly(grandchild.id)
      expect(grandchild.descendant_ids).to eq([])
    end

    it 'can reuse a precomputed map to avoid extra queries and support deep nesting' do
      root = create(:item, name: 'root')
      current = root
      30.times do |i|
        current = create(:item, parent_item_id: current.id.to_s, name: "depth-#{i}")
      end

      child_ids_by_parent_id = described_class.child_ids_by_parent_id
      descendant_ids = root.descendant_ids(child_ids_by_parent_id)

      expect(descendant_ids.size).to eq(30)
      expect(descendant_ids.uniq.size).to eq(30)
    end
  end
end
