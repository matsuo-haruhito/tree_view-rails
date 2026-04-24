require 'rails_helper'

RSpec.describe TreeView::UiConfigBuilder do
  describe '#build_for_items' do
    it 'Items向けのDOM IDとパス生成を持つUiConfigを返す' do
      context = double(:context)
      item = build_stubbed(:item, id: 8)

      allow(context).to receive(:remove_descendants_item_path).with(item, depth: 3, scope: 'all', format: :turbo_stream).and_return('/items/8/remove_descendants?depth=3&scope=all')
      allow(context).to receive(:remove_descendants_item_path).with(item, depth: 3, scope: 'grandchildren', format: :turbo_stream).and_return('/items/8/remove_descendants?depth=3&scope=grandchildren')
      allow(context).to receive(:show_descendants_item_path).with(item, depth: 2, scope: 'all', format: :turbo_stream).and_return('/items/8/show_descendants?depth=2&scope=all')
      allow(context).to receive(:show_descendants_item_path).with(item, depth: 2, scope: 'children', format: :turbo_stream).and_return('/items/8/show_descendants?depth=2&scope=children')
      allow(context).to receive(:items_path).and_return('/items')
      allow(context).to receive(:items_path).with(collapsed: 'all').and_return('/items?collapsed=all')

      config = described_class.new(context: context).build_for_items

      expect(config.node_dom_id(item)).to eq('item_8')
      expect(config.button_dom_id(item)).to eq('item_button_box_8')
      expect(config.show_button_dom_id(item)).to eq('item_show_button_8')
      expect(config.hide_descendants_path(item, 2)).to eq('/items/8/remove_descendants?depth=3&scope=all')
      expect(config.hide_descendants_path(item, 2, scope: 'grandchildren')).to eq('/items/8/remove_descendants?depth=3&scope=grandchildren')
      expect(config.show_descendants_path(item, 2)).to eq('/items/8/show_descendants?depth=2&scope=all')
      expect(config.show_descendants_path(item, 2, scope: 'children')).to eq('/items/8/show_descendants?depth=2&scope=children')
      expect(config.toggle_all_path(state: :expanded)).to eq('/items')
      expect(config.toggle_all_path(state: :collapsed)).to eq('/items?collapsed=all')
    end
  end
end
