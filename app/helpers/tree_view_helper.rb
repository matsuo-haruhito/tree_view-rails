require "json"

module TreeViewHelper
  def tree_view_rows(render_state, mode: nil, collapsed: nil, window: nil)
    previous_tree_ui = @tree_ui
    @tree_ui = render_state.ui_config
    clear_tree_view_render_caches!
    render_context = TreeView::RenderContext.new(render_state: render_state, mode: mode, collapsed: collapsed)

    if window
      return tree_view_window_rows(render_context, window)
    end

    if render_context.root_items.empty? && render_state.empty_message.present?
      return render(partial: "tree_view/tree_empty_row", locals: {empty_message: render_state.empty_message})
    end

    render(
      partial: "tree_view/tree_row",
      collection: render_context.root_items,
      as: :item,
      locals: {render_context: render_context}
    )
  ensure
    clear_tree_view_render_caches!
    @tree_ui = previous_tree_ui
  end

  def tree_view_window(render_state, offset:, limit:)
    visible_rows = TreeView::VisibleRows.new(
      tree: render_state.tree,
      root_items: render_state.root_items,
      render_state: render_state
    )

    TreeView::RenderWindow.new(visible_rows, offset: offset, limit: limit)
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

  def tree_row_transfer_data(item, tree, builder = nil)
    return {} if builder.nil?

    payload = tree_row_event_payload(item, tree, builder)
    {
      tree_transfer_payload: JSON.generate(payload),
      tree_transfer_node_key: tree.node_key_for(item),
      action: [
        "dragstart->tree-view-transfer#start",
        "dragover->tree-view-transfer#over",
        "drop->tree-view-transfer#drop"
      ].join(" ")
    }
  end

  def tree_row_event_payload(item, tree, builder = nil)
    payload = builder ? builder.call(item) : default_tree_row_event_payload(item, tree)
    return payload.to_h if payload.respond_to?(:to_h)

    raise ArgumentError, "row_event_payload_builder must return a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
  end

  def tree_render_row_data(item, tree, render_context, expanded:, depth:, transfer_data: nil)
    data = tree_row_data(item, render_context.row_data_builder, tree: tree)
    if render_context.tree_instance_key.present?
      data = data.merge(tree_instance_key: render_context.tree_instance_key)
    end

    if render_context.lazy_loading_enabled?
      lazy_loading_data = tree_lazy_loading_data(item, tree, render_context, depth: depth)
      data = data.merge(lazy_loading_data) if lazy_loading_data.any?
    end

    if render_context.error_builder&.call(item) == true
      data = data.merge(remote_state: "error")
    elsif render_context.loading_builder&.call(item) == true
      data = data.merge(remote_state: "loading")
    elsif render_context.lazy_loading_loaded_keys.include?(tree.node_key_for(item))
      data = data.merge(remote_state: "loaded")
    end

    data
      .merge(tree_depth: depth)
      .merge(tree_state_row_data(item, tree, expanded: expanded))
      .merge(transfer_data || {})
  end

  def tree_hidden_count_message(hidden_count, builder = nil)
    return hidden_count if builder.nil?

    builder.call(hidden_count)
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

  def tree_depth_label(item, depth, builder = nil)
    return nil unless builder

    builder.call(item, depth).presence
  end

  def tree_node_badge(item, builder = nil, tree: nil)
    value = builder&.call(item)
    return nil if value.nil?

    if value.respond_to?(:to_h)
      badge = value.to_h.symbolize_keys
      text = badge[:text] || badge[:label]
      return nil if text.blank?

      {
        text: text,
        class: Array(badge[:class]).flatten.compact_blank,
        title: badge[:title],
        data: badge[:data].respond_to?(:to_h) ? badge[:data].to_h : {}
      }
    else
      {text: value, class: [], title: nil, data: {}}
    end
  rescue NoMethodError
    raise ArgumentError, "badge_builder must return text or a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
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
    (depth.to_i >= 10) ? depth.to_i.to_s : "Lv#{depth}"
  end

  def tree_branch_info(item, tree = @tree)
    tree_render_traversal(tree).branch_info_for(item)
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

  def tree_view_window_rows(render_context, window_options)
    window = if window_options.is_a?(TreeView::RenderWindow)
      window_options
    elsif window_options.respond_to?(:to_h)
      options = window_options.to_h.transform_keys(&:to_sym)
      tree_view_window(render_context.render_state, offset: options.fetch(:offset), limit: options.fetch(:limit))
    else
      raise ArgumentError, "window must be a TreeView::RenderWindow or Hash-like object"
    end

    return render(partial: "tree_view/tree_empty_row", locals: {empty_message: render_context.render_state.empty_message}) if window.empty? && render_context.render_state.empty_message.present?

    render(
      partial: "tree_view/tree_window_row",
      collection: window.rows,
      as: :visible_row,
      locals: {render_context: render_context}
    )
  end

  def clear_tree_view_render_caches!
    @tree_render_traversals = {}
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

require_relative "tree_view_breadcrumb_helper"
