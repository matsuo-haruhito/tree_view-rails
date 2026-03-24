require 'rails_helper'

RSpec.describe TreeView::UiConfig do
  it 'DOM IDとパス生成の設定を呼び出せる' do
    config = described_class.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      hide_descendants_path_builder: ->(item, depth, scope) { "/hide/#{item.id}?depth=#{depth}&scope=#{scope}" },
      show_descendants_path_builder: ->(item, depth, scope) { "/show/#{item.id}?depth=#{depth}&scope=#{scope}" },
      toggle_all_path_builder: ->(state) { "/toggle?state=#{state}" }
    )

    item = build_stubbed(:item, id: 7)

    expect(config.node_dom_id(item)).to eq('node_7')
    expect(config.button_dom_id(7)).to eq('button_7')
    expect(config.show_button_dom_id(item)).to eq('show_7')
    expect(config.hide_descendants_path(item, 2)).to eq('/hide/7?depth=2&scope=all')
    expect(config.hide_descendants_path(item, 2, scope: 'grandchildren')).to eq('/hide/7?depth=2&scope=grandchildren')
    expect(config.show_descendants_path(item, 3)).to eq('/show/7?depth=3&scope=all')
    expect(config.show_descendants_path(item, 3, scope: 'children')).to eq('/show/7?depth=3&scope=children')
    expect(config.toggle_all_path(state: :collapsed)).to eq('/toggle?state=collapsed')
  end
end
