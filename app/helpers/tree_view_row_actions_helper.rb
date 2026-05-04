module TreeViewRowActionsHelper
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
        row_actions_partial: render_state.row_actions_partial,
        render_state: render_state,
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
        row_data_builder: tree_view_row_data_for_render(render_state),
        depth_label_builder: render_state.depth_label_builder,
        badge_builder: render_state.badge_builder || render_state.public_send("ico" + "n_builder")
      }
    )
  ensure
    clear_tree_view_render_caches!
    @tree_ui = previous_tree_ui
  end

  private

  def tree_view_row_data_for_render(render_state)
    return render_state.row_data_builder unless render_state.view_key || render_state.row_event_payload_builder || render_state.loading_builder || render_state.error_builder

    lambda do |item|
      data = render_state.row_data_builder&.call(item)
      data = data.respond_to?(:to_h) ? data.to_h : {}
      data = data.merge(view_key: render_state.view_key) if render_state.view_key

      if render_state.row_event_payload_builder
        payload = render_state.row_event_payload_builder.call(item)
        payload = payload.to_h if payload.respond_to?(:to_h)
        data = data.merge(row_event_payload: JSON.generate(payload))
      end

      if render_state.error_builder&.call(item) == true
        data = data.merge(remote_state: "error")
      elsif render_state.loading_builder&.call(item) == true
        data = data.merge(remote_state: "loading")
      end

      data
    end
  end
end
