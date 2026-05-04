require "spec_helper"

RSpec.describe "TreeView row event payload builder" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores a callable row event payload builder" do
    builder = ->(item) { { id: item.id } }

    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      row_event_payload_builder: builder
    )

    expect(state.row_event_payload_builder).to eq(builder)
  end

  it "rejects invalid row event payload builders" do
    expect do
      TreeView::RenderState.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        row_event_payload_builder: :invalid
      )
    end.to raise_error(ArgumentError, /row_event_payload_builder/)
  end
end
