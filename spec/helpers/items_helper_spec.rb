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
        show_descendants_path_builder: ->(_item, _depth, scope) { "/show?scope=#{scope}" },
        toggle_all_path_builder: ->(state) { "/toggle?state=#{state}" }
      )

      expect(helper.tree_node_dom_id(item, ui: ui_config)).to eq('item_42')
      expect(helper.tree_button_dom_id(item, ui: ui_config)).to eq('item_button_box_42')
      expect(helper.tree_show_button_dom_id(item, ui: ui_config)).to eq('item_show_button_42')
      expect(helper.tree_node_dom_id(42, ui: ui_config)).to eq('item_42')
      expect(helper.tree_hide_descendants_path(item, 1, ui: ui_config)).to eq('/hide?scope=all')
      expect(helper.tree_hide_descendants_path(item, 1, scope: 'grandchildren', ui: ui_config)).to eq('/hide?scope=grandchildren')
      expect(helper.tree_show_descendants_path(item, 1, ui: ui_config)).to eq('/show?scope=all')
      expect(helper.tree_show_descendants_path(item, 1, scope: 'children', ui: ui_config)).to eq('/show?scope=children')
      expect(helper.tree_toggle_all_path(state: :collapsed, ui: ui_config)).to eq('/toggle?state=collapsed')
      expect(helper.tree_expand_all_path(ui: ui_config)).to eq('/toggle?state=expanded')
      expect(helper.tree_collapse_all_path(ui: ui_config)).to eq('/toggle?state=collapsed')
    end
  end

  describe 'tree_branch_info' do
    it '祖先が末尾かどうかを含む枝情報を返す' do
      root_a = build_stubbed(:item, id: 1, parent_item_id: nil, name: 'root-a')
      root_b = build_stubbed(:item, id: 2, parent_item_id: nil, name: 'root-b')
      child_a1 = build_stubbed(:item, id: 3, parent_item_id: 1, name: 'child-a1')
      child_a2 = build_stubbed(:item, id: 4, parent_item_id: 1, name: 'child-a2')
      grandchild_a1 = build_stubbed(:item, id: 5, parent_item_id: 3, name: 'grandchild-a1')
      tree = TreeView::Tree.new(records: [root_a, root_b, child_a1, child_a2, grandchild_a1], parent_id_method: :parent_item_id)

      expect(helper.tree_branch_info(root_a, tree)).to eq(depth: 0, ancestor_last_states: [], is_last: true)
      expect(helper.tree_branch_info(child_a1, tree)).to eq(depth: 1, ancestor_last_states: [], is_last: true)
      expect(helper.tree_branch_info(grandchild_a1, tree)).to eq(depth: 2, ancestor_last_states: [true], is_last: true)
      expect(helper.tree_branch_info(root_b, tree)).to eq(depth: 0, ancestor_last_states: [], is_last: false)
    end
  end
end
