require 'rails_helper'

RSpec.describe ItemsHelper, type: :helper do
  describe 'tree dom id helpers' do
    it 'UiConfigを使ってDOM IDを組み立てる' do
      item = build_stubbed(:item, id: 42)
      ui_config = TreeView::UiConfig.new(
        node_dom_id_builder: ->(item_or_id) { "item_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
        button_dom_id_builder: ->(item_or_id) { "item_button_box_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
        show_button_dom_id_builder: ->(item_or_id) { "item_show_button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
        hide_descendants_path_builder: ->(_item, _depth, scope) { "/hide?scope=#{scope}" },
        show_descendants_path_builder: ->(_item, _depth, scope) { "/show?scope=#{scope}" }
      )

      expect(helper.tree_node_dom_id(item, ui: ui_config)).to eq('item_42')
      expect(helper.tree_button_dom_id(item, ui: ui_config)).to eq('item_button_box_42')
      expect(helper.tree_show_button_dom_id(item, ui: ui_config)).to eq('item_show_button_42')
      expect(helper.tree_node_dom_id(42, ui: ui_config)).to eq('item_42')
      expect(helper.tree_hide_descendants_path(item, 1, ui: ui_config)).to eq('/hide?scope=all')
      expect(helper.tree_hide_descendants_path(item, 1, scope: 'grandchildren', ui: ui_config)).to eq('/hide?scope=grandchildren')
      expect(helper.tree_show_descendants_path(item, 1, ui: ui_config)).to eq('/show?scope=all')
      expect(helper.tree_show_descendants_path(item, 1, scope: 'children', ui: ui_config)).to eq('/show?scope=children')
    end
  end
end
