# frozen_string_literal: true

module TreeView
  class StateStore
    def initialize(model:)
      @model = model
    end

    def find(owner:, tree_instance_key:)
      record = model.find_by(owner: owner, tree_instance_key: tree_instance_key)
      PersistedState.new(tree_instance_key: tree_instance_key, expanded_keys: record&.expanded_keys || [])
    end

    def save!(owner:, tree_instance_key:, expanded_keys:)
      record = model.find_or_initialize_by(owner: owner, tree_instance_key: tree_instance_key)
      record.expanded_keys = Array(expanded_keys)
      record.save!
      PersistedState.new(tree_instance_key: tree_instance_key, expanded_keys: record.expanded_keys)
    end

    def clear!(owner:, tree_instance_key:)
      record = model.find_by(owner: owner, tree_instance_key: tree_instance_key)
      record&.destroy!
      PersistedState.new(tree_instance_key: tree_instance_key, expanded_keys: [])
    end

    def clear_owner!(owner:)
      model.where(owner: owner).delete_all
    end

    def prune!(older_than:, owner: nil, tree_instance_key: nil)
      raise ArgumentError, "older_than is required" if older_than.nil?

      scope = model.where("updated_at < ?", older_than)
      scope = scope.where(owner: owner) unless owner.nil?
      scope = scope.where(tree_instance_key: tree_instance_key) unless tree_instance_key.nil?
      scope.delete_all
    end

    private

    attr_reader :model
  end
end
