# frozen_string_literal: true

module TreeView
  class PathTree
    attr_reader :base_tree, :paths

    def initialize(base_tree:, paths:)
      @base_tree = base_tree
      @paths = Array(paths).map { |path| Array(path) }
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
          raise ArgumentError, "cycle detected in path tree for node #{node_key.inspect}" if visiting[node_key]

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

    def build_children_by_node_key
      children_by_node_key = Hash.new { |hash, key| hash[key] = [] }
      seen_edges = {}

      paths.each do |path|
        path.each_cons(2) do |parent, child|
          parent_key = node_key_for(parent)
          child_key = node_key_for(child)
          edge_key = [parent_key, child_key]
          next if seen_edges[edge_key]

          children_by_node_key[parent_key] << child
          seen_edges[edge_key] = true
        end
      end

      children_by_node_key
    end

    def build_root_items
      roots = []
      seen_root_keys = {}

      paths.each do |path|
        root = path.first
        next unless root

        root_key = node_key_for(root)
        next if seen_root_keys[root_key]

        roots << root
        seen_root_keys[root_key] = true
      end

      roots
    end
  end
end
