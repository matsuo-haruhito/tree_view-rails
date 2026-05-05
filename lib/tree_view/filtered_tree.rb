# frozen_string_literal: true

module TreeView
  class FilteredTree
    VALID_MODES = %i[
      matched_only
      with_ancestors
      with_descendants
      with_ancestors_and_descendants
    ].freeze

    attr_reader :base_tree, :matched_items, :mode

    def initialize(base_tree:, matched_items:, mode: :with_ancestors)
      @base_tree = base_tree
      @matched_items = Array(matched_items)
      @mode = normalize_mode(mode)
      @included_by_node_key = build_included_by_node_key
      @children_by_node_key = build_children_by_node_key
      @root_items = build_root_items
    end

    def root_items(root_parent_id = nil)
      return sort_items(@root_items) if root_parent_id.nil?

      sort_items(Array(@children_by_node_key[root_parent_id]))
    end

    def children_for(record)
      sort_items(Array(@children_by_node_key[node_key_for(record)]))
    end

    def node_key_for(record)
      base_tree.node_key_for(record)
    end

    def sort_items(items)
      base_tree.sort_items(items)
    end

    def descendant_counts
      @descendant_counts ||= begin
        memo = {}
        visiting = {}

        count_descendants = lambda do |record|
          node_key = node_key_for(record)
          return memo[node_key] if memo.key?(node_key)
          raise ArgumentError, "cycle detected in filtered tree for node #{node_key.inspect}" if visiting[node_key]

          visiting[node_key] = true
          children = children_for(record)
          memo[node_key] = children.sum { |child| 1 + count_descendants.call(child) }
          visiting.delete(node_key)
          memo[node_key]
        rescue
          visiting.delete(node_key)
          raise
        end

        root_items.each { |root| count_descendants.call(root) }
        memo
      end
    end

    private

    def normalize_mode(value)
      raise_invalid_mode! unless value.respond_to?(:to_sym)

      normalized_value = value.to_sym
      return normalized_value if VALID_MODES.include?(normalized_value)

      raise_invalid_mode!
    end

    def raise_invalid_mode!
      raise ArgumentError, "filter mode must be one of: #{VALID_MODES.join(", ")}"
    end

    def build_included_by_node_key
      included = {}

      matched_items.each do |item|
        include_item!(included, item)
        include_ancestors!(included, item) if include_ancestors?
        include_descendants!(included, item) if include_descendants?
      end

      included
    end

    def include_ancestors?
      mode == :with_ancestors || mode == :with_ancestors_and_descendants
    end

    def include_descendants?
      mode == :with_descendants || mode == :with_ancestors_and_descendants
    end

    def include_item!(included, item)
      included[node_key_for(item)] ||= item
    end

    def include_ancestors!(included, item)
      ensure_parent_path_helpers!

      base_tree.path_for(item).each { |path_item| include_item!(included, path_item) }
    end

    def include_descendants!(included, item)
      stack = base_tree.children_for(item).reverse

      until stack.empty?
        current = stack.pop
        current_key = node_key_for(current)
        next if included[current_key]

        included[current_key] = current
        base_tree.children_for(current).reverse_each { |child| stack << child }
      end
    end

    def ensure_parent_path_helpers!
      return if base_tree.respond_to?(:path_for)

      raise ArgumentError, "filter mode #{mode.inspect} requires parent path helpers"
    end

    def build_children_by_node_key
      return {} if mode == :matched_only

      children_by_node_key = Hash.new { |hash, key| hash[key] = [] }
      included_keys = @included_by_node_key.keys.to_h { |key| [key, true] }

      @included_by_node_key.each_value do |item|
        base_tree.children_for(item).each do |child|
          child_key = node_key_for(child)
          next unless included_keys[child_key]

          children_by_node_key[node_key_for(item)] << child
        end
      end

      children_by_node_key
    end

    def build_root_items
      included_keys = @included_by_node_key.keys.to_h { |key| [key, true] }
      child_keys = {}

      @children_by_node_key.each_value do |children|
        children.each { |child| child_keys[node_key_for(child)] = true }
      end

      @included_by_node_key.each_value.filter_map do |item|
        item_key = node_key_for(item)
        next if child_keys[item_key]

        item if included_keys[item_key]
      end
    end
  end
end
