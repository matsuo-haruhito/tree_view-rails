# frozen_string_literal: true

module TreeView
  module CycleDiagnostics
    def cycle_report
      ensure_records_path_helpers!

      records.filter_map do |record|
        cycle_path_for(record)
      end
    end

    def validate_no_cycles!
      reports = cycle_report
      return true if reports.empty?

      keys = reports.map { |report| report[:cycle_keys].map(&:inspect).join(" -> ") }.join(", ")
      raise ArgumentError, "cycle detected in tree: #{keys}"
    end

    private

    def cycle_path_for(record)
      visiting = {}
      path = []
      current = record

      while current
        key = node_key_for(current)
        if visiting.key?(key)
          cycle_items = path[visiting[key]..]
          return {
            item: current,
            key: key,
            cycle_items: cycle_items,
            cycle_keys: cycle_items.map { |item| node_key_for(item) }
          }
        end

        visiting[key] = path.length
        path << current
        current = parent_for(current)
      end

      nil
    end
  end
end

TreeView::Tree.prepend(TreeView::CycleDiagnostics)
