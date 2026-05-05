module TreeViewHelper
  module RenderScope
    def tree_initial_depth_boundary?(depth, max_initial_depth)
      !max_initial_depth.nil? && depth >= max_initial_depth
    end

    def tree_render_children?(depth, max_render_depth)
      max_render_depth.nil? || depth < max_render_depth
    end

    def tree_render_leaf_distance?(item, tree, max_leaf_distance)
      return true if max_leaf_distance.nil?

      distance = tree_leaf_distance(item, tree)
      !distance.nil? && distance <= max_leaf_distance
    end

    def tree_leaf_distance(item, tree)
      tree_render_traversal(tree).leaf_distance_for(item)
    end

    def tree_toggle_scope(depth:, max_toggle_depth_from_root:, max_toggle_leaf_distance: nil, leaf_distance: nil, mode: :all, ui: @tree_ui)
      resolved = resolved_ui(ui)
      return mode.to_s unless resolved.object_scope?

      TreeView::ToggleScope.new(
        mode: mode,
        current_depth: depth,
        max_depth_from_root: max_toggle_depth_from_root,
        current_leaf_distance: leaf_distance,
        max_leaf_distance: max_toggle_leaf_distance
      )
    end

    def tree_expanded_key?(item, tree, expanded_keys)
      Array(expanded_keys).include?(tree.node_key_for(item))
    end

    def tree_collapsed_key?(item, tree, collapsed_keys)
      Array(collapsed_keys).include?(tree.node_key_for(item))
    end

    def tree_branch_info(item, tree = @tree)
      tree_render_traversal(tree).branch_info_for(item)
    end

    def tree_toggle_mode(mode = nil)
      resolved_mode = (mode || (@tree_ui&.static? ? :static : :turbo)).to_sym
      return resolved_mode if %i[static turbo].include?(resolved_mode)

      raise ArgumentError, "TreeView toggle mode must be :static or :turbo, got: #{mode.inspect}"
    end
  end
end
