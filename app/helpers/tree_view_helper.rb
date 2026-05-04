require "json"

module TreeViewHelper
  def tree_view_rows(render_state, mode: nil, collapsed: nil)
    previous_tree_ui = @tree_ui
    @tree_ui = render_state.ui_config
    clear_tree_view_render_caches!

    if render_state.root_items.empty? && render_state.empty_message.present?
      return render(partial: "tree_view/tree_empty_row", locals: { empty_message: render_state.empty_message })
    end

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
        max_render_depth: render_state.max_render_depth,
        max_leaf_distance: render_state.max_leaf_distance,
        max_toggle_depth_from_root: render_state.max_toggle_depth_from_root,
        max_toggle_leaf_distance: render_state.max_toggle_leaf_distance,
        expanded_keys: render_state.expanded_keys,
        collapsed_keys: render_state.collapsed_keys,
        current_key: render_state.current_key,
        selection_enabled: render_state.selection_enabled?,
        selection_visibility: render_state.selection_visibility,
        selection_payload_builder: render_state.selection_payload_builder,
        selection_checkbox_name: render_state.selection_checkbox_name,
        selection_disabled_builder: render_state.selection_disabled_builder,
        selection_disabled_reason_builder: render_state.selection_disabled_reason_builder,
        selection_selected_keys: render_state.selection_selected_keys,
        hidden_message_builder: render_state.hidden_message_builder,
        row_class_builder: render_state.row_class_builder,
        row_data_builder: render_state.row_data_builder,
        depth_label_builder: render_state.depth_label_builder
      }
    )
  ensure
    clear_tree_view_render_caches!
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

  def tree_selection_checkbox_dom_id(item, ui: @tree_ui)
    "#{tree_node_dom_id(item, ui: ui)}_selection"
  end

  def tree_row_classes(item, builder = nil)
    Array(builder&.call(item)).flatten.compact_blank
  end

  def tree_row_data(item, builder = nil, tree: nil)
    data = builder&.call(item)
    return {} if data.nil?
    return data.to_h if data.respond_to?(:to_h)

    raise ArgumentError, "row_data_builder must return a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
  end

  def tree_hidden_count_message(hidden_count, builder = nil)
    return hidden_count if builder.nil?

    builder.call(hidden_count)
  end

  def tree_depth_label(item, depth, builder = nil)
    return nil unless builder

    builder.call(item, depth).presence
  end

  def tree_selection_payload(item, tree, builder = nil)
    payload = builder ? builder.call(item) : default_tree_selection_payload(item, tree)
    return payload.to_h if payload.respond_to?(:to_h)

    raise ArgumentError, "selection_payload_builder must return a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
  end

  def tree_selection_value(item, tree, builder = nil)
    JSON.generate(tree_selection_payload(item, tree, builder))
  end

  def tree_selection_disabled?(item, builder = nil)
    builder ? builder.call(item) == true : false
  end

  def tree_selection_disabled_reason(item, builder = nil)
    return nil unless builder

    builder.call(item).presence
  end

  def tree_selection_checked?(item, tree, selected_keys = nil)
    Array(selected_keys).include?(tree.node_key_for(item))
  end

  def tree_selection_visible?(item, tree, depth, visibility)
    case visibility.to_sym
    when :all
      true
    when :roots
      depth.to_i.zero?
    when :leaves
      tree.children_for(item).empty?
    when :none
      false
    else
      raise ArgumentError, "selection visibility must be one of: all, roots, leaves, none"
    end
  end

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
    tree_leaf_distances(tree)[tree.node_key_for(item)]
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

  def clear_tree_view_render_caches!
    @tree_leaf_distance_maps = {}
    @tree_branch_maps = {}
  end

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

  def tree_diagnostic_node_label(item, tree = nil)
    return "node_key=#{tree.node_key_for(item).inspect}" if tree

    if item.respond_to?(:id)
      "item_id=#{item.id.inspect}"
    else
      "item=#{item.inspect}"
    end
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

  def tree_leaf_distances(tree)
    @tree_leaf_distance_maps ||= {}
    @tree_leaf_distance_maps[tree.object_id] ||= begin
      distances = {}

      walk = lambda do |node|
        node_key = tree.node_key_for(node)
        return distances[node_key] if distances.key?(node_key)

        children = tree.children_for(node)
        distances[node_key] = if children.empty?
                                0
                              else
                                child_distances = children.map { |child| walk.call(child) }.compact
                                child_distances.empty? ? nil : child_distances.min + 1
                              end
      end

      tree.root_items.each { |root| walk.call(root) }
      distances
    end
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

require_relative "tree_view_breadcrumb_helper"
