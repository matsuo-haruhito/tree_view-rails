module TreeViewHelper
  module Dom
    def tree_node_dom_id(item_or_id, ui: @tree_ui)
      resolved_ui(ui).node_dom_id(item_or_id)
    end

    def tree_button_dom_id(item, ui: @tree_ui)
      resolved_ui(ui).button_dom_id(item)
    end

    def tree_show_button_dom_id(item, ui: @tree_ui)
      resolved_ui(ui).show_button_dom_id(item)
    end

    def tree_selection_checkbox_dom_id(item, ui: @tree_ui)
      "#{tree_node_dom_id(item, ui: ui)}_selection"
    end

    def tree_hide_descendants_path(item, display_depth, scope: "all", ui: @tree_ui)
      resolved_ui(ui).hide_descendants_path(item, display_depth, scope: scope)
    end

    def tree_show_descendants_path(item, toggle_depth, scope: "all", ui: @tree_ui)
      resolved_ui(ui).show_descendants_path(item, toggle_depth, scope: scope)
    end

    def tree_load_children_path(item, depth, scope: "all", ui: @tree_ui)
      resolved_ui(ui).load_children_path(item, depth, scope: scope)
    end

    def tree_toggle_all_path(state:, ui: @tree_ui)
      resolved_ui(ui).toggle_all_path(state: state)
    end

    def tree_expand_all_path(ui: @tree_ui)
      tree_toggle_all_path(state: :expanded, ui: ui)
    end

    def tree_collapse_all_path(ui: @tree_ui)
      tree_toggle_all_path(state: :collapsed, ui: ui)
    end
  end
end
