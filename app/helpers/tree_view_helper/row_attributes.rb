module TreeViewHelper
  module RowAttributes
    def tree_row_classes(item, builder = nil)
      Array(builder&.call(item)).flatten.compact_blank
    end

    def tree_row_data(item, builder = nil, tree: nil, row_context: nil)
      data = if builder && tree_row_data_builder_accepts_context?(builder)
        builder.call(item, row_context || {})
      else
        builder&.call(item)
      end
      return {} if data.nil?
      return data.to_h if data.respond_to?(:to_h)

      raise ArgumentError, "row_data_builder must return a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
    end

    def tree_render_row_data(item, tree, render_context, expanded:, depth:, row_context: nil, transfer_data: nil)
      data = tree_row_data(item, render_context.row_data_builder, tree: tree, row_context: row_context)
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

      data = data
        .merge(tree_depth: depth)
        .merge(tree_state_row_data(item, tree, expanded: expanded))
        .merge(transfer_data || {})

      if tree_toggle_mode(render_context.mode) == :client
        data = data.merge(
          tree_view_client_node_key: tree.node_key_for(item),
          tree_view_client_depth: depth,
          tree_view_client_expanded: expanded
        )
      end

      data
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

    def tree_row_data_builder_accepts_context?(builder)
      arity = if builder.respond_to?(:arity)
        builder.arity
      elsif builder.respond_to?(:method) && builder.respond_to?(:call)
        builder.method(:call).arity
      end

      arity.nil? || arity.negative? || arity >= 2
    end
  end
end
