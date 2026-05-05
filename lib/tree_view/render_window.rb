# frozen_string_literal: true

module TreeView
  class RenderWindow
    include Enumerable

    attr_reader :visible_rows, :offset, :limit

    def initialize(visible_rows, offset:, limit:)
      @visible_rows = visible_rows.to_a.freeze
      @offset = normalize_non_negative_integer(offset, :offset)
      @limit = normalize_positive_integer(limit, :limit)
    end

    def each(&block)
      rows.each(&block)
    end

    def rows
      visible_rows.slice(offset, limit) || []
    end

    def total_count
      visible_rows.length
    end

    def start_index
      return total_count if total_count.zero?

      [offset, total_count].min
    end

    def end_index
      return 0 if rows.empty?

      start_index + rows.length
    end

    def next_offset
      return nil unless next?

      offset + limit
    end

    def previous_offset
      return nil unless previous?

      [offset - limit, 0].max
    end

    def next?
      offset + limit < total_count
    end

    def previous?
      offset.positive?
    end

    def empty?
      rows.empty?
    end

    private

    def normalize_non_negative_integer(value, name)
      return value if value.is_a?(Integer) && value >= 0

      raise ArgumentError, "#{name} must be a non-negative Integer"
    end

    def normalize_positive_integer(value, name)
      return value if value.is_a?(Integer) && value.positive?

      raise ArgumentError, "#{name} must be a positive Integer"
    end
  end
end
