# frozen_string_literal: true

module TreeViewStateOwner
  extend ActiveSupport::Concern

  included do
    has_many :tree_view_states, as: :owner, dependent: :destroy
  end

  def tree_view_state_for(view_key)
    record = tree_view_states.find_by(view_key: view_key)
    TreeView::PersistedState.new(view_key: view_key, expanded_keys: record&.expanded_keys || [])
  end

  def save_tree_view_state!(view_key, expanded_keys:)
    record = tree_view_states.find_or_initialize_by(view_key: view_key)
    record.expanded_keys = Array(expanded_keys)
    record.save!
    TreeView::PersistedState.new(view_key: view_key, expanded_keys: record.expanded_keys)
  end
end
