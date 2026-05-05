require "spec_helper"

RSpec.describe "TreeView::RenderState option combinations" do
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

  it "prefers individual initial expansion options over grouped options" do
    state = build_state(
      initial_state: :expanded,
      max_initial_depth: 1,
      expanded_keys: [9],
      collapsed_keys: [8],
      initial_expansion: {
        default: :collapsed,
        max_depth: 2,
        expanded_keys: [1, 2],
        collapsed_keys: [3]
      }
    )

    expect(state.initial_state).to eq(:expanded)
    expect(state.max_initial_depth).to eq(1)
    expect(state.expanded_keys).to eq([9])
    expect(state.collapsed_keys).to eq([8])
  end

  it "keeps render and toggle scope options independent" do
    state = build_state(
      render_scope: {max_depth: 2, max_leaf_distance: 1},
      toggle_scope: {max_depth_from_root: 3, max_leaf_distance: 4}
    )

    expect(state.max_render_depth).to eq(2)
    expect(state.max_leaf_distance).to eq(1)
    expect(state.max_toggle_depth_from_root).to eq(3)
    expect(state.max_toggle_leaf_distance).to eq(4)
  end

  it "rejects conflicting expansion keys" do
    expect do
      build_state(expanded_keys: [1, 2], collapsed_keys: [2, 3])
    end.to raise_error(ArgumentError, /expanded_keys and collapsed_keys/)
  end
end
