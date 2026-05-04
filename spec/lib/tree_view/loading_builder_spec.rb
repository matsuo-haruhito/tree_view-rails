require "spec_helper"

RSpec.describe "TreeView loading builder" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores a callable loading builder" do
    builder = ->(item) { item.loading? }

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      loading_builder: builder
    )

    expect(state.loading_builder).to eq(builder)
  end

  it "rejects invalid loading builders" do
    expect do
      TreeView::RenderState.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        loading_builder: :invalid
      )
    end.to raise_error(ArgumentError, /loading_builder/)
  end
end
