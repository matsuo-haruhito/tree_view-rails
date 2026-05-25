module TreeViewHelper
  module LazyLoading
    def tree_children_container_dom_id(item, ui: @tree_ui)
      "#{tree_node_dom_id(item, ui: ui)}_children"
    end

    def tree_remote_state_placeholder_dom_id(item, ui: @tree_ui)
      "#{tree_node_dom_id(item, ui: ui)}_remote_state"
    end

    def tree_remote_state_placeholder_attributes(item, state: nil, ui: @tree_ui)
      attributes = {id: tree_remote_state_placeholder_dom_id(item, ui: ui)}
      return attributes if state.nil?

      attributes.merge(data: {tree_remote_state: state.to_s})
    end

    def tree_lazy_loading_data(item, tree, render_context, depth:)
      path = tree_load_children_path(item, depth, scope: render_context.lazy_loading_scope, ui: render_context.render_state.ui_config)
      return {} if path.nil?

      {
        tree_lazy: true,
        tree_children_url: path,
        tree_loaded: render_context.lazy_loading_loaded_keys.include?(tree.node_key_for(item))
      }
    end
  end
end
