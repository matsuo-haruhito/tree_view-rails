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

    private

    attr_reader :model
  end
end
