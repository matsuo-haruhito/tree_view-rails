# frozen_string_literal: true

module TreeView
  module Sorters
    module_function

    def by(*methods)
      raise ArgumentError, "at least one sort key is required" if methods.empty?

      lambda do |items, _tree|
        items.sort_by do |item|
          methods.map { |method_name| sortable_value(item.public_send(method_name)) }
        end
      end
    end

    def descendant_count(direction = :asc)
      direction = direction.to_sym
      raise ArgumentError, "direction must be :asc or :desc" unless %i[asc desc].include?(direction)

      lambda do |items, tree|
        sorted = items.sort_by { |item| tree.descendant_counts[tree.node_key_for(item)].to_i }
        direction == :desc ? sorted.reverse : sorted
      end
    end

    def sortable_value(value)
      value.nil? ? "" : value
    end
  end
end
