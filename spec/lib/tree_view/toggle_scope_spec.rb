require "spec_helper"

RSpec.describe TreeView::ToggleScope do
  it "returns current depth when max depth is omitted" do
    scope = described_class.new(mode: :all, current_depth: 3)

    expect(scope.mode).to eq(:all)
    expect(scope.current_depth).to eq(3)
    expect(scope.max_depth_from_root).to be_nil
    expect(scope.toggle_depth).to eq(3)
    expect(scope.within_scope?).to eq(false)
  end

  it "keeps mode as metadata without changing boundary decisions" do
    all_scope = described_class.new(mode: :all, current_depth: 1, max_depth_from_root: 3)
    child_scope = described_class.new(mode: :children, current_depth: 1, max_depth_from_root: 3)

    expect(child_scope.mode).to eq(:children)
    expect(child_scope.toggle_depth).to eq(all_scope.toggle_depth)
    expect(child_scope.within_scope?).to eq(all_scope.within_scope?)
  end

  it "raises a clear error when mode is not symbolizable" do
    expect do
      described_class.new(mode: nil, current_depth: 1)
    end.to raise_error(ArgumentError, /mode must be symbol-like/)

    expect do
      described_class.new(mode: 1, current_depth: 1)
    end.to raise_error(ArgumentError, /mode must be symbol-like/)
  end

  it "returns max depth while current depth is inside root-based scope" do
    scope = described_class.new(mode: :all, current_depth: 1, max_depth_from_root: 3)

    expect(scope.toggle_depth).to eq(3)
    expect(scope.within_scope?).to eq(true)
    expect(scope.root_depth_within_scope?).to eq(true)
  end

  it "returns current depth when current depth is outside root-based scope" do
    scope = described_class.new(mode: :all, current_depth: 3, max_depth_from_root: 2)

    expect(scope.toggle_depth).to eq(3)
    expect(scope.within_scope?).to eq(false)
  end

  it "treats boundary depth as individual node toggle" do
    scope = described_class.new(mode: :all, current_depth: 2, max_depth_from_root: 2)

    expect(scope.toggle_depth).to eq(2)
    expect(scope.within_scope?).to eq(false)
  end

  it "returns max leaf distance while current leaf distance is inside leaf-based scope" do
    scope = described_class.new(mode: :all, current_depth: 3, current_leaf_distance: 1, max_leaf_distance: 2)

    expect(scope.toggle_depth).to eq(3)
    expect(scope.toggle_leaf_distance).to eq(2)
    expect(scope.within_scope?).to eq(true)
    expect(scope.leaf_distance_within_scope?).to eq(true)
  end

  it "returns current leaf distance when current leaf distance is outside leaf-based scope" do
    scope = described_class.new(mode: :all, current_depth: 3, current_leaf_distance: 3, max_leaf_distance: 2)

    expect(scope.toggle_leaf_distance).to eq(3)
    expect(scope.within_scope?).to eq(false)
  end

  it "treats boundary leaf distance as individual node toggle" do
    scope = described_class.new(mode: :all, current_depth: 3, current_leaf_distance: 2, max_leaf_distance: 2)

    expect(scope.toggle_leaf_distance).to eq(2)
    expect(scope.within_scope?).to eq(false)
  end

  it "is within scope when either root-based or leaf-based scope matches" do
    scope = described_class.new(
      mode: :all,
      current_depth: 3,
      max_depth_from_root: 2,
      current_leaf_distance: 1,
      max_leaf_distance: 2
    )

    expect(scope.root_depth_within_scope?).to eq(false)
    expect(scope.leaf_distance_within_scope?).to eq(true)
    expect(scope.within_scope?).to eq(true)
  end
end
