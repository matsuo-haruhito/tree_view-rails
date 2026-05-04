require "spec_helper"

RSpec.describe TreeView::RenderContext do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  def build_state(**options)
    TreeView::RenderState.new(
      tree: tree,
      root_items: [:root],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      **options
    )
  end

  it "delegates render configuration to render state" do
    row_class_builder = ->(_item) { ["row"] }
    state = build_state(
      max_initial_depth: 1,
      max_render_depth: 2,
      max_leaf_distance: 3,
      max_toggle_depth_from_root: 4,
      max_toggle_leaf_distance: 5,
      expanded_keys: [1],
      collapsed_keys: [2],
      selectable: true,
      selection: { visibility: :leaves, selected_keys: [3] },
      row_class_builder: row_class_builder,
      badge_builder: ->(_item) { "badge" }
    )

    context = described_class.new(render_state: state, mode: :static, collapsed: true)

    expect(context.tree).to eq(tree)
    expect(context.root_items).to eq([:root])
    expect(context.row_partial).to eq("items/tree_columns")
    expect(context.mode).to eq(:static)
    expect(context).to be_collapsed
    expect(context.max_initial_depth).to eq(1)
    expect(context.max_render_depth).to eq(2)
    expect(context.max_leaf_distance).to eq(3)
    expect(context.max_toggle_depth_from_root).to eq(4)
    expect(context.max_toggle_leaf_distance).to eq(5)
    expect(context.expanded_keys).to eq([1])
    expect(context.collapsed_keys).to eq([2])
    expect(context).to be_selection_enabled
    expect(context.selection_visibility).to eq(:leaves)
    expect(context.selection_selected_keys).to eq([3])
    expect(context.row_class_builder).to eq(row_class_builder)
    expect(context.badge_builder.call(:item)).to eq("badge")
  end

  it "uses effective initial state when collapsed override is not provided" do
    state = build_state(initial_state: :collapsed)
    context = described_class.new(render_state: state)

    expect(context).to be_collapsed
  end
end
