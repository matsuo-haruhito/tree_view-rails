# frozen_string_literal: true

module TreeView
  class RenderTraversal
    def initialize(tree)
      @tree = tree
      @leaf_distances = nil
      @branch_map = nil
      @max_depth = nil
    end

    def max_depth
      @max_depth ||= begin
        max_depth = 0
        seen_depths = {}
        stack = tree.root_items.reverse.map { |root| [root, 0, {}] }

        until stack.empty?
          node, depth, ancestor_keys = stack.pop
          node_key = tree.node_key_for(node)
          raise ArgumentError, "cycle detected in tree for node #{node_key.inspect}" if ancestor_keys[node_key]

          previous_depth = seen_depths[node_key]
          next if previous_depth && previous_depth >= depth

          seen_depths[node_key] = depth
          max_depth = depth if depth > max_depth

          next_ancestor_keys = ancestor_keys.merge(node_key => true)
          tree.children_for(node).reverse_each do |child|
            stack << [child, depth + 1, next_ancestor_keys]
          end
        end

        max_depth
      end
    end

    def leaf_distance_for(item)
      leaf_distances[tree.node_key_for(item)]
    end

    def leaf_distances
      @leaf_distances ||= begin
        distances = {}
        stack = tree.root_items.reverse.map { |root| [root, false, {}] }

        until stack.empty?
          node, expanded, ancestor_keys = stack.pop
          node_key = tree.node_key_for(node)

          if expanded
            children = tree.children_for(node)
            distances[node_key] = if children.empty?
                                    0
                                  else
                                    child_distances = children.map { |child| distances[tree.node_key_for(child)] }.compact
                                    child_distances.empty? ? nil : child_distances.min + 1
                                  end
            next
          end

          next if distances.key?(node_key)
          raise ArgumentError, "cycle detected in tree for node #{node_key.inspect}" if ancestor_keys[node_key]

          next_ancestor_keys = ancestor_keys.merge(node_key => true)
          stack << [node, true, ancestor_keys]
          tree.children_for(node).reverse_each do |child|
            child_key = tree.node_key_for(child)
            raise ArgumentError, "cycle detected in tree for node #{child_key.inspect}" if next_ancestor_keys[child_key]

            stack << [child, false, next_ancestor_keys] unless distances.key?(child_key)
          end
        end

        distances
      end
    end

    def branch_info_for(item)
      branch_map.fetch(tree.node_key_for(item), {
        depth: 0,
        ancestor_last_states: [],
        is_last: true
      })
    end

    def branch_map
      @branch_map ||= begin
        map = {}
        stack = [[tree.root_items, 0, [], {}]]

        until stack.empty?
          nodes, depth, ancestor_last_states, ancestor_keys = stack.pop
          sorted_nodes = tree.sort_items(nodes)
          child_frames = []

          sorted_nodes.each_with_index do |node, index|
            node_key = tree.node_key_for(node)
            raise ArgumentError, "cycle detected in tree for node #{node_key.inspect}" if ancestor_keys[node_key]

            is_last = index == sorted_nodes.length - 1
            map[node_key] = {
              depth: depth,
              ancestor_last_states: ancestor_last_states.dup,
              is_last: is_last
            }

            children = tree.children_for(node)
            next if children.empty?

            next_ancestor_last_states = depth.zero? ? ancestor_last_states : ancestor_last_states + [is_last]
            child_frames << [children, depth + 1, next_ancestor_last_states, ancestor_keys.merge(node_key => true)]
          end

          child_frames.reverse_each { |frame| stack << frame }
        end

        map
      end
    end

    private

    attr_reader :tree
  end
end
