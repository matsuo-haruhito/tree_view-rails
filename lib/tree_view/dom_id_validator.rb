# frozen_string_literal: true

module TreeView
  class DomIdValidator
    ID_TYPES = %i[node button show_button selection_checkbox].freeze

    def self.validate!(render_state)
      new(render_state).validate!
    end

    def initialize(render_state)
      @render_state = render_state
      @tree = render_state.tree
      @ui_config = render_state.ui_config
    end

    def validate!
      occurrences = Hash.new { |hash, key| hash[key] = [] }

      each_renderable_item do |item|
        add_occurrence(occurrences, :node, node_dom_id(item), item)
        add_occurrence(occurrences, :button, button_dom_id(item), item)
        add_occurrence(occurrences, :show_button, show_button_dom_id(item), item)
        add_occurrence(occurrences, :selection_checkbox, selection_checkbox_dom_id(item), item) if render_state.selection_enabled?
      end

      collisions = occurrences.select { |_dom_id, entries| entries.size > 1 }
      return true if collisions.empty?

      raise ArgumentError, collision_message(collisions)
    end

    private

    attr_reader :render_state, :tree, :ui_config

    def each_renderable_item(&block)
      walk_items(tree.sort_items(render_state.root_items), 0, &block)
    end

    def walk_items(items, depth, &block)
      items.each do |item|
        yield item if render_self?(item, depth)

        next unless render_children?(depth)

        walk_items(tree.sort_items(tree.children_for(item)), depth + 1, &block)
      end
    end

    def render_self?(item, depth)
      render_depth?(depth) && render_leaf_distance?(item)
    end

    def render_depth?(depth)
      render_state.max_render_depth.nil? || depth <= render_state.max_render_depth
    end

    def render_children?(depth)
      render_state.max_render_depth.nil? || depth < render_state.max_render_depth
    end

    def render_leaf_distance?(item)
      return true if render_state.max_leaf_distance.nil?

      distance = leaf_distances[tree.node_key_for(item)]
      !distance.nil? && distance <= render_state.max_leaf_distance
    end

    def leaf_distances
      @leaf_distances ||= begin
        distances = {}

        walker = lambda do |node|
          node_key = tree.node_key_for(node)
          return distances[node_key] if distances.key?(node_key)

          children = tree.children_for(node)
          distances[node_key] = if children.empty?
            0
          else
            child_distances = children.map { |child| walker.call(child) }.compact
            child_distances.empty? ? nil : child_distances.min + 1
          end
        end

        tree.root_items.each { |root| walker.call(root) }
        distances
      end
    end

    def add_occurrence(occurrences, type, dom_id, item)
      return if dom_id.nil? || dom_id.to_s.empty?

      occurrences[dom_id.to_s] << {
        type: type,
        node_key: tree.node_key_for(item)
      }
    end

    def node_dom_id(item)
      ui_config.node_dom_id(item)
    end

    def button_dom_id(item)
      ui_config.button_dom_id(item)
    end

    def show_button_dom_id(item)
      ui_config.show_button_dom_id(item)
    end

    def selection_checkbox_dom_id(item)
      "#{node_dom_id(item)}_selection"
    end

    def collision_message(collisions)
      details = collisions.map do |dom_id, entries|
        usages = entries.map { |entry| "#{entry.fetch(:type)}(#{entry.fetch(:node_key).inspect})" }.join(", ")
        "#{dom_id.inspect} used by #{usages}"
      end.join("; ")

      "TreeView DOM ID collision detected: #{details}"
    end
  end

  class RenderState
    def validate_dom_ids!
      DomIdValidator.validate!(self)
    end

    def validate_unique_dom_ids!
      validate_dom_ids!
    end
  end
end
