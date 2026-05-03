# frozen_string_literal: true

module TreeViewStateHelper
  def tree_view_state_data(render_state)
    data = { controller: "tree-view-state" }
    if render_state.respond_to?(:view_key) && render_state.view_key.present?
      data[:tree_view_state_view_key_value] = render_state.view_key
    end
    data
  end

  def tree_state_row_data(item, tree, expanded:)
    {
      tree_view_state_target: "node",
      tree_view_state_node_key: tree.node_key_for(item),
      tree_view_state_expanded: expanded
    }
  end
end
