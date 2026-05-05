module TreeViewHelper
  module Support
    private

    def resolved_ui(ui)
      resolved = ui || @tree_ui || default_tree_ui
      return resolved if resolved

      raise ArgumentError, "TreeView ui_config is required. Pass ui: or set @tree_ui."
    end

    def default_tree_ui
      nil
    end

    def default_tree_selection_payload(item, tree)
      {
        key: tree.node_key_for(item),
        id: item.respond_to?(:id) ? item.id : tree.node_key_for(item),
        type: item.class.name
      }
    end

    def default_tree_row_event_payload(item, tree)
      {
        key: tree.node_key_for(item),
        id: item.respond_to?(:id) ? item.id : tree.node_key_for(item),
        type: item.class.name
      }
    end

    def tree_diagnostic_node_label(item, tree = nil)
      return "node_key=#{tree.node_key_for(item).inspect}" if tree

      if item.respond_to?(:id)
        "item_id=#{item.id.inspect}"
      else
        "item=#{item.inspect}"
      end
    end

    def tree_max_depth(tree)
      tree_render_traversal(tree).max_depth
    end

    def tree_render_traversal(tree)
      @tree_render_traversals ||= {}
      @tree_render_traversals[tree.object_id] ||= TreeView::RenderTraversal.new(tree)
    end
  end
end
