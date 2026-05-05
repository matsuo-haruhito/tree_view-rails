module TreeViewHelper
  module LazyLoading
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
