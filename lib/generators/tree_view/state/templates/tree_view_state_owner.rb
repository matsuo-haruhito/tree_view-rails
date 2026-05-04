# frozen_string_literal: true

module TreeViewStateOwner
  extend ActiveSupport::Concern

  included do
    has_many :tree_view_states, as: :owner, dependent: :destroy
  end

  def tree_view_state_for(tree_instance_key)
    record = tree_view_states.find_by(tree_instance_key: tree_instance_key)
    TreeView::PersistedState.new(tree_instance_key: tree_instance_key, expanded_keys: record&.expanded_keys || [])
  end

  def save_tree_view_state!(tree_instance_key, expanded_keys:)
    record = tree_view_states.find_or_initialize_by(tree_instance_key: tree_instance_key)
    record.expanded_keys = Array(expanded_keys)
    record.save!
    TreeView::PersistedState.new(tree_instance_key: tree_instance_key, expanded_keys: record.expanded_keys)
  end
end
