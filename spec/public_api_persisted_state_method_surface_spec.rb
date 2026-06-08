# frozen_string_literal: true

require "spec_helper"

PersistedStateContractRecord = Struct.new(:owner, :tree_instance_key, :expanded_keys) do
  def save!
    true
  end

  def destroy!
    PersistedStateContractModel.record = nil
    true
  end
end

class PersistedStateContractModel
  class << self
    attr_accessor :record

    def find_by(owner:, tree_instance_key:)
      return nil unless record
      return record if record.owner == owner && record.tree_instance_key == tree_instance_key

      nil
    end

    def find_or_initialize_by(owner:, tree_instance_key:)
      self.record ||= PersistedStateContractRecord.new(owner, tree_instance_key, [])
    end
  end
end

RSpec.describe "Persisted state public method surface" do
  before do
    PersistedStateContractModel.record = nil
  end

  it "keeps PersistedState.from as the documented normalization entrypoint" do
    expect(TreeView::PersistedState).to respond_to(:from)
    expect(TreeView::PersistedState.method(:from).parameters).to eq([[:req, :value]])

    state = TreeView::PersistedState.new(tree_instance_key: "documents:index", expanded_keys: ["node:1"])

    expect(TreeView::PersistedState.from(state)).to equal(state)
    expect(TreeView::PersistedState.from(nil)).to be_nil
  end

  it "keeps StateStore find, save, and clear keyword boundaries public" do
    store = TreeView::StateStore.new(model: PersistedStateContractModel)

    expect(store).to respond_to(:find)
    expect(store).to respond_to(:save!)
    expect(store).to respond_to(:clear!)
    expect(store.method(:find).parameters).to eq([[:keyreq, :owner], [:keyreq, :tree_instance_key]])
    expect(store.method(:save!).parameters).to eq([
      [:keyreq, :owner],
      [:keyreq, :tree_instance_key],
      [:keyreq, :expanded_keys]
    ])
    expect(store.method(:clear!).parameters).to eq([[:keyreq, :owner], [:keyreq, :tree_instance_key]])
  end

  it "keeps representative StateStore return behavior available" do
    store = TreeView::StateStore.new(model: PersistedStateContractModel)

    saved_state = store.save!(
      owner: :user,
      tree_instance_key: "documents:index",
      expanded_keys: ["node:1", "node:2"]
    )

    expect(saved_state).to be_a(TreeView::PersistedState)
    expect(saved_state.tree_instance_key).to eq("documents:index")
    expect(saved_state.expanded_keys).to eq(["node:1", "node:2"])
    expect(store.find(owner: :user, tree_instance_key: "documents:index").expanded_keys).to eq(["node:1", "node:2"])
  end

  it "keeps StateStore clear idempotent for missing records" do
    store = TreeView::StateStore.new(model: PersistedStateContractModel)

    empty_state = store.clear!(owner: :user, tree_instance_key: "documents:index")

    expect(empty_state).to be_a(TreeView::PersistedState)
    expect(empty_state.tree_instance_key).to eq("documents:index")
    expect(empty_state.expanded_keys).to eq([])
  end
end
