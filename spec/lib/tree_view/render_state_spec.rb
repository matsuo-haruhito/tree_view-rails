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

  it 'initial_state を保持できる' do
    state = described_class.new(
      tree: instance_double(TreeView::Tree),
      root_items: [],
      row_partial: 'items/tree_columns',
      ui_config: instance_double(TreeView::UiConfig),
      initial_state: :collapsed
    )

    expect(state.initial_state).to eq(:collapsed)
    expect(state.effective_initial_state).to eq(:collapsed)
  end

  it 'initial_state が未指定なら global config を使う' do
    TreeView.configure do |config|
      config.initial_state = :collapsed
    end

    state = described_class.new(
      tree: instance_double(TreeView::Tree),
      root_items: [],
      row_partial: 'items/tree_columns',
      ui_config: instance_double(TreeView::UiConfig)
    )

    expect(state.initial_state).to be_nil
    expect(state.effective_initial_state).to eq(:collapsed)
  end

  it 'RenderState の initial_state が global config より優先される' do
    TreeView.configure do |config|
      config.initial_state = :expanded
    end

    state = described_class.new(
      tree: instance_double(TreeView::Tree),
      root_items: [],
      row_partial: 'items/tree_columns',
      ui_config: instance_double(TreeView::UiConfig),
      initial_state: :collapsed
    )

    expect(state.effective_initial_state).to eq(:collapsed)
  end

  it '不正な initial_state は受け付けない' do
    expect do
      described_class.new(
        tree: instance_double(TreeView::Tree),
        root_items: [],
        row_partial: 'items/tree_columns',
        ui_config: instance_double(TreeView::UiConfig),
        initial_state: :invalid
      )
    end.to raise_error(ArgumentError, /initial_state/)
  end
end
