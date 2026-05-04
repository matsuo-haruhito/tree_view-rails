require "spec_helper"

RSpec.describe "TreeView view key" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores view key as a string" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      view_key: :source
    )

    expect(state.view_key).to eq("source")
  end

  it "keeps view key nil when omitted" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config
    )

    expect(state.view_key).to be_nil
  end
end
