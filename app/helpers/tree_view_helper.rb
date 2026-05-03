module TreeViewHelper
  def tree_view_rows(render_state, mode: nil, collapsed: nil)
    previous_tree_ui = @tree_ui
    @tree_ui = render_state.ui_config

    render(
      partial: "tree_view/tree_row",
      collection: render_state.root_items,
      as: :item,
      locals: {
        tree: render_state.tree,
        row_partial: render_state.row_partial,
        mode: mode,
        collapsed: collapsed.nil? ? render_state.effective_initial_state == :collapsed : collapsed,
        max_initial_depth: render_state.max_initial_depth,
        expanded_keys: render_state.expanded_keys,
        row_class_builder: render_state.row_class_builder,
        row_data_builder: render_state.row_data_builder
      }
    )
  ensure
    @tree_ui = previous_tree_ui
  end

  def tree_node_dom_id(item_or_id, ui: @tree_ui)
    resolved_ui(ui).node_dom_id(item_or_id)
  end

  def tree_button_dom_id(item, ui: @tree_ui)
    resolved_ui(ui).button_dom_id(item)
  end

  def tree_show_button_dom_id(item, ui: @tree_ui)
    resolved_ui(ui).show_button_dom_id(item)
  end

  def tree_row_classes(item, builder = nil)
    Array(builder&.call(item)).flatten.compact_blank
  end

  def tree_row_data(item, builder = nil)
    data = builder&.call(item)
    return {} if data.nil?
    return data.to_h if data.respond_to?(:to_h)

    raise ArgumentError, "row_data_builder must return a Hash-like object"
  end

  def tree_initial_depth_boundary?(depth, max_initial_depth)
    !max_initial_depth.nil? && depth >= max_initial_depth
  end

  def tree_expanded_key?(item, tree, expanded_keys)
    Array(expanded_keys).include?(tree.node_key_for(item))
  end

  def tree_depth_slots(depth)
    Array.new(depth.to_i.clamp(0, 100))
  end

  def tree_depth_columns(tree)
    tree_max_depth(tree) + 1
  end

  def tree_level_column(depth)
    depth.to_i + 1
  end

  def tree_toggle_label(depth)
    depth.to_i >= 10 ? depth.to_i.to_s : "Lv#{depth}"
  end

  def tree_branch_info(item, tree = @tree)
    tree_branch_map(tree).fetch(tree.node_key_for(item), {
      depth: 0,
      ancestor_last_states: [],
      is_last: true
    })
  end

  def tree_hide_descendants_path(item, display_depth, scope: 'all', ui: @tree_ui)
    resolved_ui(ui).hide_descendants_path(item, display_depth, scope: scope)
  end

  def tree_show_descendants_path(item, toggle_depth, scope: 'all', ui: @tree_ui)
    resolved_ui(ui).show_descendants_path(item, toggle_depth, scope: scope)
  end

  def tree_context_menu_label(item)
    item.respond_to?(:name) ? item.name : item.to_s
  end

  # view からは path の作り方を知らずに全体開閉を呼べるようにする。
  def tree_toggle_all_path(state:, ui: @tree_ui)
    resolved_ui(ui).toggle_all_path(state: state)
  end

  def tree_expand_all_path(ui: @tree_ui)
    tree_toggle_all_path(state: :expanded, ui: ui)
  end

  def tree_collapse_all_path(ui: @tree_ui)
    tree_toggle_all_path(state: :collapsed, ui: ui)
  end

  def tree_toggle_mode(mode = nil)
    resolved_mode = (mode || (@tree_ui&.static? ? :static : :turbo)).to_sym
    return resolved_mode if %i[static turbo].include?(resolved_mode)

    raise ArgumentError, "TreeView toggle mode must be :static or :turbo, got: #{mode.inspect}"
  end

  private

  def resolved_ui(ui)
    resolved = ui || @tree_ui || default_tree_ui
    return resolved if resolved

    raise ArgumentError, "TreeView ui_config is required. Pass ui: or set @tree_ui."
  end

  def default_tree_ui
    nil
  end

  def tree_max_depth(tree)
    memo = {}

    walk = lambda do |node, depth|
      node_key = tree.node_key_for(node)
      previous = memo[node_key]
      return previous if previous && previous >= depth

      memo[node_key] = depth
      children = tree.children_for(node)
      return depth if children.empty?

      children.map { |child| walk.call(child, depth + 1) }.max
    end

    tree.root_items.map { |root| walk.call(root, 0) }.max.to_i
  end

  def tree_branch_map(tree)
    @tree_branch_maps ||= {}
    @tree_branch_maps[tree.object_id] ||= begin
      branch_map = {}

      walk = lambda do |nodes, depth, ancestor_last_states|
        sorted_nodes = tree.sort_items(nodes)

        sorted_nodes.each_with_index do |node, index|
          is_last = index == sorted_nodes.length - 1
          branch_map[tree.node_key_for(node)] = {
            depth: depth,
            ancestor_last_states: ancestor_last_states.dup,
            is_last: is_last
          }

          children = tree.children_for(node)
          next if children.empty?

          next_ancestor_last_states = depth.zero? ? ancestor_last_states : ancestor_last_states + [is_last]
          walk.call(children, depth + 1, next_ancestor_last_states)
        end
      end

      walk.call(tree.root_items, 0, [])
      branch_map
    end
  end
end
