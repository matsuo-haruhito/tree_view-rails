require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '.descendant_counts' do
    it 'ツリー内の各ノードに対する子孫数を返す' do
      root = create(:item, name: 'root')
      child1 = create(:item, parent_item_id: root.id, name: 'child1')
      child2 = create(:item, parent_item_id: root.id, name: 'child2')
      grandchild = create(:item, parent_item_id: child1.id, name: 'grandchild')

      items_by_parent_id = Item.all.group_by(&:parent_item_id)

      counts = described_class.descendant_counts(items_by_parent_id)

      expect(counts[root.id]).to eq(3)
      expect(counts[child1.id]).to eq(1)
      expect(counts[child2.id]).to eq(0)
      expect(counts[grandchild.id]).to eq(0)
    end
  end

  describe '.child_ids_by_parent_id' do
    it '親IDから子ID一覧へのマップを1回の走査で構築する' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')

      map = described_class.child_ids_by_parent_id

      expect(map[nil]).to include(root.id)
      expect(map[root.id]).to include(child.id)
    end
  end

  describe '.tree_snapshot' do
    it '一覧描画に必要なスナップショットを返す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')

      snapshot = described_class.tree_snapshot

      expect(snapshot.items_by_parent_id[nil]).to include(root)
      expect(snapshot.items_by_parent_id[root.id]).to include(child)
      expect(snapshot.descendant_counts[root.id]).to eq(1)
      expect(snapshot.root_items).to include(root)
    end
  end

  describe '#descendant_ids' do
    it '子孫IDを再帰的にすべて返す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')
      grandchild = create(:item, parent_item_id: child.id, name: 'grandchild')

      expect(root.descendant_ids).to contain_exactly(child.id, grandchild.id)
      expect(child.descendant_ids).to contain_exactly(grandchild.id)
      expect(grandchild.descendant_ids).to eq([])
    end

    it '事前計算済みマップを再利用して深い階層でも取得できる' do
      root = create(:item, name: 'root')
      current = root
      30.times do |i|
        current = create(:item, parent_item_id: current.id, name: "depth-#{i}")
      end

      child_ids_by_parent_id = described_class.child_ids_by_parent_id
      descendant_ids = root.descendant_ids(child_ids_by_parent_id)

      expect(descendant_ids.size).to eq(30)
      expect(descendant_ids.uniq.size).to eq(30)
    end
  end
end
