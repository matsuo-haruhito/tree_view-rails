require 'rails_helper'

RSpec.describe TreeView::RenderState do
  it '描画に必要な tree/root_items/row_partial を保持する' do
    tree = instance_double(TreeView::Tree)
    ui_config = instance_double(TreeView::UiConfig)
    root_items = [double(:item)]
    row_partial = 'items/tree_columns'

    state = described_class.new(tree: tree, root_items: root_items, row_partial: row_partial, ui_config: ui_config)

    expect(state.tree).to eq(tree)
    expect(state.root_items).to eq(root_items)
    expect(state.row_partial).to eq(row_partial)
    expect(state.ui_config).to eq(ui_config)
  end
end
