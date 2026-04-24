require 'rails_helper'

RSpec.describe TreeView::Traversal do
  describe '.child_ids_by_parent_id' do
    it '親IDから子ID一覧のマップを構築する' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')

      map = described_class.child_ids_by_parent_id(Item.pluck(:id, :parent_item_id))

      expect(map[nil]).to include(root.id)
      expect(map[root.id]).to include(child.id)
    end
  end

  describe '.descendant_ids' do
    it '指定ノードの子孫IDを再帰的に返す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')
      grandchild = create(:item, parent_item_id: child.id, name: 'grandchild')
      child_ids_by_parent_id = described_class.child_ids_by_parent_id(Item.pluck(:id, :parent_item_id))

      expect(described_class.descendant_ids(root.id, child_ids_by_parent_id)).to contain_exactly(child.id, grandchild.id)
      expect(described_class.descendant_ids(child.id, child_ids_by_parent_id)).to contain_exactly(grandchild.id)
      expect(described_class.descendant_ids(grandchild.id, child_ids_by_parent_id)).to eq([])
    end
  end
end
