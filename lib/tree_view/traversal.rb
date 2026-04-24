# frozen_string_literal: true

module TreeView
  module Traversal
    module_function

    def child_ids_by_parent_id(pairs)
      pairs.each_with_object({}) do |(item_id, parent_item_id), map|
        (map[parent_item_id] ||= []) << item_id
      end
    end

    def descendant_ids(node_id, child_ids_by_parent_id, min_depth: 1, max_depth: nil)
      result = []
      stack = Array(child_ids_by_parent_id[node_id]).map { |child_id| [child_id, 1] }

      until stack.empty?
        child_id, depth = stack.pop
        next if max_depth && depth > max_depth

        result << child_id if depth >= min_depth
        stack.concat(Array(child_ids_by_parent_id[child_id]).map { |descendant_id| [descendant_id, depth + 1] })
      end

      result
    end
  end
end
