require 'rails_helper'

RSpec.describe 'items/index', type: :view do
  it 'TreeViewの行パーシャルで親子を描画する' do
    root = build_stubbed(:item, id: 1, parent_item_id: nil, name: 'root', comment: 'root-comment')
    child = build_stubbed(:item, id: 2, parent_item_id: root.id, name: 'child', comment: 'child-comment')
    tree = TreeView::Tree.new(records: [root, child], parent_id_method: :parent_item_id)

    assign(:tree, tree)
    assign(:root_items, [root])
    assign(:root_page, Kaminari.paginate_array([root]).page(1).per(10))
    assign(:row_partial, 'items/tree_columns')
    assign(:tree_ui, TreeView::UiConfigBuilder.new(context: view).build_for_items)
    assign(:node_counts, { total: 2, roots: 1, leaves: 1 })

    render

    expect(rendered).to include('item_1')
    expect(rendered).to include('item_2')
    expect(rendered).to include('root-comment')
    expect(rendered).to include('child-comment')
    expect(rendered).to include('総ノード数')
    expect(rendered).to include('子ノードを畳む')
    expect(rendered).to include('tree-toggle__branch-slot')
    expect(rendered).to include('1件中')
    expect(rendered).to include('turbo-cable-stream-source')
  end
end
