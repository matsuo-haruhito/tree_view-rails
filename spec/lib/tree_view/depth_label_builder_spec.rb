require "spec_helper"

RSpec.describe "TreeView depth label builder" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores a callable depth label builder" do
    builder = ->(_item, depth) { "Level #{depth + 1}" }

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      depth_label_builder: builder
    )

    expect(state.depth_label_builder).to eq(builder)
  end

  it "rejects invalid depth label builders" do
    expect do
      TreeView::RenderState.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        depth_label_builder: :invalid
      )
    end.to raise_error(ArgumentError, /depth_label_builder/)
  end
end
