require "spec_helper"

RSpec.describe TreeView::PersistedState do
  it "stores values" do
    state = described_class.new(view_key: "documents", expanded_keys: [1, 2])

    expect(state.view_key).to eq("documents")
    expect(state.expanded_keys).to eq([1, 2])
  end

  it "requires a view key" do
    expect do
      described_class.new(view_key: nil)
    end.to raise_error(ArgumentError, /view_key/)
  end

  it "builds from hash-like values" do
    state = described_class.from(view_key: "documents", expanded_keys: [1, 2])

    expect(state.view_key).to eq("documents")
    expect(state.expanded_keys).to eq([1, 2])
  end

  it "returns nil from nil" do
    expect(described_class.from(nil)).to be_nil
  end
end
