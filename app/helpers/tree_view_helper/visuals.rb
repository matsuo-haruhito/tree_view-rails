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

    def tree_context_menu_label(item)
      item.respond_to?(:name) ? item.name : item.to_s
    end
  end
end
