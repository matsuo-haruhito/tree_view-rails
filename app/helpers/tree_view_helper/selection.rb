require "json"

module TreeViewHelper
  module Selection
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
  end
end
