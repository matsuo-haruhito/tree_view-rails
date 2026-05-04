# frozen_string_literal: true

module TreeViewStateHelper
  def tree_view_state_data(render_state)
    controllers = ["tree-view-state"]
    controllers << "tree-view-selection" if render_state.selection_enabled?
    controllers << "tree-view-transfer" if render_state.respond_to?(:row_event_payload_builder) && render_state.row_event_payload_builder
    controllers << "tree-view-remote-state" if render_state.respond_to?(:lazy_loading_enabled?) && render_state.lazy_loading_enabled?

    data = { controller: controllers.join(" ") }
    if render_state.respond_to?(:tree_instance_key)
      tree_instance_key = render_state.tree_instance_key
      if !tree_instance_key.nil? && tree_instance_key.to_s != ""
        data[:tree_view_state_tree_instance_key_value] = tree_instance_key
      end
    end

    if render_state.selection_enabled?
      data[:action] = append_tree_view_action(data[:action], "change->tree-view-selection#toggle")
      data[:tree_view_selection_cascade_value] = true if render_state.selection_cascade?
      data[:tree_view_selection_indeterminate_value] = true if render_state.selection_indeterminate?
      data[:tree_view_selection_max_count_value] = render_state.selection_max_count if render_state.selection_max_count
    end

    if render_state.respond_to?(:lazy_loading_enabled?) && render_state.lazy_loading_enabled?
      data[:action] = append_tree_view_action(data[:action], "tree-view:loading->tree-view-remote-state#loading")
      data[:action] = append_tree_view_action(data[:action], "tree-view:loaded->tree-view-remote-state#loaded")
      data[:action] = append_tree_view_action(data[:action], "tree-view:error->tree-view-remote-state#error")
      data[:action] = append_tree_view_action(data[:action], "tree-view:retry->tree-view-remote-state#retry")
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

  private

  def append_tree_view_action(existing_action, action)
    actions = existing_action.to_s.split
    actions << action unless actions.include?(action)
    actions.join(" ")
  end
end

TreeViewHelper.include(TreeViewStateHelper) if defined?(TreeViewHelper)
