require "spec_helper"

DummyRecord = Struct.new(:owner, :tree_instance_key, :expanded_keys, :updated_at) do
  def save!
    true
  end

  def destroy!
    DummyModel.records.delete(self)
    true
  end
end

class DummyRelation
  def initialize(records)
    @records = records
  end

  def where(conditions)
    filtered = records.select do |record|
      conditions.all? { |attribute, expected| record.public_send(attribute) == expected }
    end

    self.class.new(filtered)
  end

  def delete_all
    count = records.count
    records.each { |record| DummyModel.records.delete(record) }
    count
  end

  private

  attr_reader :records
end

class DummyModel
  class << self
    attr_accessor :records

    def record
      records.first
    end

    def record=(value)
      self.records = value ? [value] : []
    end

    def find_by(owner:, tree_instance_key:)
      records.find do |record|
        record.owner == owner && record.tree_instance_key == tree_instance_key
      end
    end

    def find_or_initialize_by(owner:, tree_instance_key:)
      find_by(owner: owner, tree_instance_key: tree_instance_key).tap do |record|
        return record if record
      end

      DummyRecord.new(owner, tree_instance_key, []).tap { |record| records << record }
    end

    def where(query, value = nil)
      if query.is_a?(Hash)
        return DummyRelation.new(records).where(query)
      end

      raise ArgumentError, "unexpected query" unless query == "updated_at < ?"

      DummyRelation.new(records.select { |record| record.updated_at && record.updated_at < value })
    end
  end
end

RSpec.describe TreeView::StateStore do
  before do
    DummyModel.records = []
  end

  it "returns an empty persisted state when no record exists" do
    store = described_class.new(model: DummyModel)

    state = store.find(owner: :user, tree_instance_key: "documents")

    expect(state).to be_a(TreeView::PersistedState)
    expect(state.tree_instance_key).to eq("documents")
    expect(state.expanded_keys).to eq([])
  end

  it "loads expanded keys from an existing record" do
    DummyModel.record = DummyRecord.new(:user, "documents", ["node-1"])
    store = described_class.new(model: DummyModel)

    state = store.find(owner: :user, tree_instance_key: "documents")

    expect(state.expanded_keys).to eq(["node-1"])
  end

  it "saves expanded keys and returns a persisted state" do
    store = described_class.new(model: DummyModel)

    state = store.save!(owner: :user, tree_instance_key: "documents", expanded_keys: ["node-1"])

    expect(DummyModel.record.expanded_keys).to eq(["node-1"])
    expect(state.tree_instance_key).to eq("documents")
    expect(state.expanded_keys).to eq(["node-1"])
  end

  it "clears an existing record and returns an empty persisted state" do
    DummyModel.record = DummyRecord.new(:user, "documents", ["node-1"])
    store = described_class.new(model: DummyModel)

    state = store.clear!(owner: :user, tree_instance_key: "documents")

    expect(DummyModel.record).to be_nil
    expect(state).to be_a(TreeView::PersistedState)
    expect(state.tree_instance_key).to eq("documents")
    expect(state.expanded_keys).to eq([])
    expect(store.find(owner: :user, tree_instance_key: "documents").expanded_keys).to eq([])
  end

  it "treats clearing a missing record as idempotent" do
    store = described_class.new(model: DummyModel)

    state = store.clear!(owner: :user, tree_instance_key: "documents")

    expect(state.tree_instance_key).to eq("documents")
    expect(state.expanded_keys).to eq([])
  end

  it "clears all persisted states for one owner" do
    user_documents = DummyRecord.new(:user, "documents", ["node-1"])
    user_projects = DummyRecord.new(:user, "projects", ["node-2"])
    other_owner = DummyRecord.new(:admin, "documents", ["node-3"])
    DummyModel.records = [user_documents, user_projects, other_owner]
    store = described_class.new(model: DummyModel)

    count = store.clear_owner!(owner: :user)

    expect(count).to eq(2)
    expect(DummyModel.records).to contain_exactly(other_owner)
  end

  it "returns zero when clearing an owner without records" do
    other_owner = DummyRecord.new(:admin, "documents", ["node-3"])
    DummyModel.records = [other_owner]
    store = described_class.new(model: DummyModel)

    count = store.clear_owner!(owner: :user)

    expect(count).to eq(0)
    expect(DummyModel.records).to contain_exactly(other_owner)
  end

  it "prunes records older than the given timestamp" do
    cutoff = Time.utc(2026, 1, 1)
    old_record = DummyRecord.new(:user, "documents", ["node-1"], cutoff - 60)
    fresh_record = DummyRecord.new(:user, "documents", ["node-2"], cutoff + 60)
    DummyModel.records = [old_record, fresh_record]
    store = described_class.new(model: DummyModel)

    count = store.prune!(older_than: cutoff)

    expect(count).to eq(1)
    expect(DummyModel.records).to contain_exactly(fresh_record)
  end

  it "prunes only matching owner records when an owner is provided" do
    cutoff = Time.utc(2026, 1, 1)
    matching_record = DummyRecord.new(:user, "documents", ["node-1"], cutoff - 60)
    other_owner_record = DummyRecord.new(:admin, "documents", ["node-2"], cutoff - 60)
    DummyModel.records = [matching_record, other_owner_record]
    store = described_class.new(model: DummyModel)

    count = store.prune!(older_than: cutoff, owner: :user)

    expect(count).to eq(1)
    expect(DummyModel.records).to contain_exactly(other_owner_record)
  end

  it "prunes only matching tree instance records when a tree instance key is provided" do
    cutoff = Time.utc(2026, 1, 1)
    matching_record = DummyRecord.new(:user, "documents", ["node-1"], cutoff - 60)
    other_tree_record = DummyRecord.new(:user, "projects", ["node-2"], cutoff - 60)
    DummyModel.records = [matching_record, other_tree_record]
    store = described_class.new(model: DummyModel)

    count = store.prune!(older_than: cutoff, tree_instance_key: "documents")

    expect(count).to eq(1)
    expect(DummyModel.records).to contain_exactly(other_tree_record)
  end

  it "requires an older_than timestamp before pruning" do
    store = described_class.new(model: DummyModel)

    expect { store.prune!(older_than: nil) }.to raise_error(ArgumentError, "older_than is required")
  end
end
