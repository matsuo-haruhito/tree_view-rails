require "spec_helper"

RSpec.describe "TreeView error builder" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores a callable error builder" do
    builder = ->(item) { item.error? }

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      error_builder: builder
    )

    expect(state.error_builder).to eq(builder)
  end

  it "rejects invalid error builders" do
    expect do
      TreeView::RenderState.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        error_builder: :invalid
      )
    end.to raise_error(ArgumentError, /error_builder/)
  end
end
