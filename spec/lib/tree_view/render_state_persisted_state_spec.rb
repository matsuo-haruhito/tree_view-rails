require "spec_helper"

RSpec.describe "TreeView::RenderState persisted state" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  def build_state(**options)
    TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      **options
    )
  end

  it "uses persisted expanded keys when expanded_keys is omitted" do
    persisted_state = TreeView::PersistedState.new(view_key: "documents", expanded_keys: [1, 2])

    state = build_state(persisted_state: persisted_state)

    expect(state.persisted_state).to eq(persisted_state)
    expect(state.view_key).to eq("documents")
    expect(state.expanded_keys).to eq([1, 2])
  end

  it "prefers explicit expanded_keys over persisted expanded keys" do
    persisted_state = TreeView::PersistedState.new(view_key: "documents", expanded_keys: [1, 2])

    state = build_state(persisted_state: persisted_state, expanded_keys: [9])

    expect(state.expanded_keys).to eq([9])
  end

  it "accepts hash-like persisted state" do
    state = build_state(persisted_state: { view_key: "documents", expanded_keys: [3] })

    expect(state.view_key).to eq("documents")
    expect(state.expanded_keys).to eq([3])
  end
end
