# frozen_string_literal: true

require "active_support/concern"

module TreeView
  module PersistedStateController
    extend ActiveSupport::Concern

    def save_tree_view_persisted_state!(model:, owner:, tree_instance_key:, expanded_keys:)
      tree_view_state_store(model: model).save!(
        owner: owner,
        tree_instance_key: tree_instance_key,
        expanded_keys: normalize_tree_view_expanded_keys(expanded_keys)
      )
    end

    private

    def tree_view_state_store(model:)
      TreeView::StateStore.new(model: model)
    end

    def normalize_tree_view_expanded_keys(expanded_keys)
      return [] if expanded_keys.nil?

      values = expanded_keys.is_a?(String) ? expanded_keys.split(",") : Array(expanded_keys)
      values.map { |value| value.to_s.strip }.reject(&:empty?)
    end
  end
end
