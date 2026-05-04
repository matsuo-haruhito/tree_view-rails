# frozen_string_literal: true

module TreeViewStateHelper
  def tree_view_state_data(render_state)
    controllers = ["tree-view-state"]
    controllers << "tree-view-transfer" if render_state.respond_to?(:row_event_payload_builder) && render_state.row_event_payload_builder

    data = { controller: controllers.join(" ") }
    if render_state.respond_to?(:tree_instance_key) && render_state.tree_instance_key.present?
      data[:tree_view_state_tree_instance_key_value] = render_state.tree_instance_key
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

TreeViewHelper.include(TreeViewStateHelper) if defined?(TreeViewHelper)
