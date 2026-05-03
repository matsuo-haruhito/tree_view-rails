require "spec_helper"

RSpec.describe TreeView::RenderState do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  it "stores tree, root_items, row_partial, and ui_config" do
    root_items = [double(:node)]
    row_partial = "items/tree_columns"

    state = described_class.new(tree: tree, root_items: root_items, row_partial: row_partial, ui_config: ui_config)

    expect(state.tree).to eq(tree)
    expect(state.root_items).to eq(root_items)
    expect(state.row_partial).to eq(row_partial)
    expect(state.ui_config).to eq(ui_config)
  end

  it "stores max_initial_depth when given" do
    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      max_initial_depth: 2
    )

    expect(state.max_initial_depth).to eq(2)
  end

  it "rejects invalid max_initial_depth values" do
    expect do
      described_class.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        max_initial_depth: "2"
      )
    end.to raise_error(ArgumentError, /max_initial_depth/)
  end

  it "stores max_render_depth when given" do
    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      max_render_depth: 2
    )

    expect(state.max_render_depth).to eq(2)
  end

  it "rejects invalid max_render_depth values" do
    expect do
      described_class.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        max_render_depth: -1
      )
    end.to raise_error(ArgumentError, /max_render_depth/)
  end

  it "stores max_leaf_distance when given" do
    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      max_leaf_distance: 2
    )

    expect(state.max_leaf_distance).to eq(2)
  end

  it "rejects invalid max_leaf_distance values" do
    expect do
      described_class.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        max_leaf_distance: -1
      )
    end.to raise_error(ArgumentError, /max_leaf_distance/)
  end

  it "stores max_toggle_depth_from_root when given" do
    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      max_toggle_depth_from_root: 2
    )

    expect(state.max_toggle_depth_from_root).to eq(2)
  end

  it "rejects invalid max_toggle_depth_from_root values" do
    expect do
      described_class.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        max_toggle_depth_from_root: "2"
      )
    end.to raise_error(ArgumentError, /max_toggle_depth_from_root/)
  end

  it "stores expanded_keys when given" do
    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      expanded_keys: [1, 2]
    )

    expect(state.expanded_keys).to eq([1, 2])
  end

  it "stores row attribute builders when given" do
    row_class_builder = ->(item) { item.name }
    row_data_builder = ->(item) { { name: item.name } }

    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      row_class_builder: row_class_builder,
      row_data_builder: row_data_builder
    )

    expect(state.row_class_builder).to eq(row_class_builder)
    expect(state.row_data_builder).to eq(row_data_builder)
  end

  it "rejects invalid row attribute builders" do
    expect do
      described_class.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        row_class_builder: :invalid
      )
    end.to raise_error(ArgumentError, /row_class_builder/)
  end

  it "stores initial_state when given" do
    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      initial_state: :collapsed
    )

    expect(state.initial_state).to eq(:collapsed)
    expect(state.effective_initial_state).to eq(:collapsed)
  end

  it "falls back to global config when initial_state is omitted" do
    TreeView.configure do |config|
      config.initial_state = :collapsed
    end

    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config
    )

    expect(state.initial_state).to be_nil
    expect(state.effective_initial_state).to eq(:collapsed)
  end

  it "prefers render state over global config" do
    TreeView.configure do |config|
      config.initial_state = :expanded
    end

    state = described_class.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      initial_state: :collapsed
    )

    expect(state.effective_initial_state).to eq(:collapsed)
  end

  it "rejects invalid initial_state" do
    expect do
      described_class.new(
        tree: tree,
        root_items: [],
        row_partial: "items/tree_columns",
        ui_config: ui_config,
        initial_state: :invalid
      )
    end.to raise_error(ArgumentError, /initial_state/)
  end
end
