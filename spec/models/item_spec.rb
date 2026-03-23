require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '#descendants' do
    it '自己参照の関連として子孫を再帰的に返す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')
      grandchild = create(:item, parent_item_id: child.id, name: 'grandchild')

      expect(root.descendants).to contain_exactly(child, grandchild)
      expect(child.descendants).to contain_exactly(grandchild)
      expect(grandchild.descendants).to eq([])
    end
  end
end
