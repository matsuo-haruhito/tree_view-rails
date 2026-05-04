require "spec_helper"

RSpec.describe "TreeView tree instance key" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores tree instance key as a string" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      tree_instance_key: :source
    )

    expect(state.tree_instance_key).to eq("source")
  end

  it "keeps tree instance key nil when omitted" do
    state = TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config
    )

    expect(state.tree_instance_key).to be_nil
  end
end
