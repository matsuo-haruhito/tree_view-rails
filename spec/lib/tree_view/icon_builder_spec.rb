require "spec_helper"

RSpec.describe "TreeView icon builder" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores a callable icon builder" do
    builder = ->(item) { item.name }

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      icon_builder: builder
    )

    expect(state.icon_builder).to eq(builder)
  end

  it "rejects invalid icon builders" do
    expect do
      TreeView::RenderState.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        icon_builder: :invalid
      )
    end.to raise_error(ArgumentError, /icon_builder/)
  end
end
