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

  it "returns max depth while current depth is inside root-based scope" do
    scope = described_class.new(mode: :all, current_depth: 1, max_depth_from_root: 3)

    expect(scope.toggle_depth).to eq(3)
    expect(scope.within_scope?).to eq(true)
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
end
