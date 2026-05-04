require "spec_helper"

RSpec.describe TreeView::PersistedState do
  it "stores values" do
    state = described_class.new(tree_instance_key: "documents", expanded_keys: [1, 2])

    expect(state.tree_instance_key).to eq("documents")
    expect(state.expanded_keys).to eq([1, 2])
  end

  it "requires a tree instance key" do
    expect do
      described_class.new(tree_instance_key: nil)
    end.to raise_error(ArgumentError, /tree_instance_key/)
  end

  it "builds from hash-like values" do
    state = described_class.from(tree_instance_key: "documents", expanded_keys: [1, 2])

    expect(state.tree_instance_key).to eq("documents")
    expect(state.expanded_keys).to eq([1, 2])
  end

  it "returns nil from nil" do
    expect(described_class.from(nil)).to be_nil
  end
end
