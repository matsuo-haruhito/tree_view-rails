# frozen_string_literal: true

module TreeView
  class RowContext
    attr_reader :render_context, :item, :depth

    def initialize(render_context:, item:, depth:)
      @render_context = render_context
      @item = item
      @depth = depth
    end

    def tree
      render_context.tree
    end

    def children
      @children ||= tree.children_for(item)
    end

    def node_key
      @node_key ||= tree.node_key_for(item)
    end

    def descendant_count
      tree.descendant_counts[node_key].to_i
    end

    def selection_enabled?
      render_context.selection_enabled?
    end

    def selection_visibility
      render_context.selection_visibility
    end

    def expanded_keys
      render_context.expanded_keys
    end

    def collapsed_keys
      render_context.collapsed_keys
    end

    def current?
      render_context.current_key == node_key
    end

    def initial_depth_boundary?
      !render_context.max_initial_depth.nil? && depth >= render_context.max_initial_depth
    end

    def render_children?
      render_context.max_render_depth.nil? || depth < render_context.max_render_depth
    end
  end
end
