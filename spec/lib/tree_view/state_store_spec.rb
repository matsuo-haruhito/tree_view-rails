require "spec_helper"

RSpec.describe TreeView::StateStore do
  DummyRecord = Struct.new(:owner, :view_key, :expanded_keys) do
    def save!
      true
    end
  end

  class DummyModel
    class << self
      attr_accessor :record

      def find_by(owner:, view_key:)
        return nil unless record
        return record if record.owner == owner && record.view_key == view_key

        nil
      end

      def find_or_initialize_by(owner:, view_key:)
        self.record ||= DummyRecord.new(owner, view_key, [])
      end
    end
  end

  before do
    DummyModel.record = nil
  end

  it "returns an empty persisted state when no record exists" do
    store = described_class.new(model: DummyModel)

    state = store.find(owner: :user, view_key: "documents")

    expect(state).to be_a(TreeView::PersistedState)
    expect(state.view_key).to eq("documents")
    expect(state.expanded_keys).to eq([])
  end

  it "loads expanded keys from an existing record" do
    DummyModel.record = DummyRecord.new(:user, "documents", ["node-1"])
    store = described_class.new(model: DummyModel)

    state = store.find(owner: :user, view_key: "documents")

    expect(state.expanded_keys).to eq(["node-1"])
  end

  it "saves expanded keys and returns a persisted state" do
    store = described_class.new(model: DummyModel)

    state = store.save!(owner: :user, view_key: "documents", expanded_keys: ["node-1"])

    expect(DummyModel.record.expanded_keys).to eq(["node-1"])
    expect(state.view_key).to eq("documents")
    expect(state.expanded_keys).to eq(["node-1"])
  end
end
