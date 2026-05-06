module TreeViewHelper
  module Visuals
    def tree_hidden_count_message(hidden_count, builder = nil)
      return hidden_count if builder.nil?

      builder.call(hidden_count)
    end

    def tree_depth_label(item, depth, builder = nil)
      return nil unless builder

      builder.call(item, depth).presence
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

    def tree_toggle_icon(item, state, builder = nil, depth:, tree:, children: nil, hidden_count: nil, mode: nil, leaf_distance: nil)
      return nil unless builder

      context = {
        state: state.to_sym,
        depth: depth,
        tree: tree,
        children: Array(children),
        hidden_count: hidden_count,
        mode: mode,
        leaf_distance: leaf_distance
      }
      value = builder.call(item, context[:state], context)
      return nil if value.nil?

      if value.respond_to?(:to_h)
        icon = value.to_h.symbolize_keys
        content = icon[:html] || icon[:text] || icon[:label] || icon[:icon]
        return nil if content.blank?

        tag.span(
          content,
          class: ["tree-toggle__icon", icon[:class]].flatten.compact_blank,
          title: icon[:title],
          data: icon[:data].respond_to?(:to_h) ? icon[:data].to_h : {},
          aria: {hidden: icon.fetch(:aria_hidden, true)}
        )
      else
        value
      end
    rescue NoMethodError
      raise ArgumentError, "toggle_icon_builder must return text or a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
    end

    def tree_context_menu_label(item)
      item.respond_to?(:name) ? item.name : item.to_s
    end
  end
end
