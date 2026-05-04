# frozen_string_literal: true

module TreeView
  module RenderStateRowStatus
    ROW_DISABLED_CLASSES = ["tree-view-row--disabled"].freeze
    ROW_READONLY_CLASSES = ["tree-view-row--readonly"].freeze

    attr_reader :row_disabled_builder,
                :row_readonly_builder,
                :row_disabled_reason_builder

    def initialize(**options)
      original_row_class_builder = options[:row_class_builder]
      original_row_data_builder = options[:row_data_builder]
      @row_disabled_builder = options.delete(:row_disabled_builder)
      @row_readonly_builder = options.delete(:row_readonly_builder)
      @row_disabled_reason_builder = options.delete(:row_disabled_reason_builder)

      validate_row_status_builder!(@row_disabled_builder, :row_disabled_builder)
      validate_row_status_builder!(@row_readonly_builder, :row_readonly_builder)
      validate_row_status_builder!(@row_disabled_reason_builder, :row_disabled_reason_builder)

      options[:row_class_builder] = build_row_status_class_builder(original_row_class_builder)
      options[:row_data_builder] = build_row_status_data_builder(original_row_data_builder)

      super(**options)
    end

    private

    def build_row_status_class_builder(original_builder)
      return original_builder if row_disabled_builder.nil? && row_readonly_builder.nil?

      lambda do |item|
        classes = Array(original_builder&.call(item)).flatten.compact
        classes.concat(ROW_DISABLED_CLASSES) if row_disabled_builder&.call(item) == true
        classes.concat(ROW_READONLY_CLASSES) if row_readonly_builder&.call(item) == true
        classes
      end
    end

    def build_row_status_data_builder(original_builder)
      return original_builder if row_disabled_builder.nil? && row_readonly_builder.nil? && row_disabled_reason_builder.nil?

      lambda do |item|
        data = original_builder&.call(item)
        unless data.nil? || data.respond_to?(:to_h)
          raise ArgumentError, "row_data_builder must return a Hash-like object"
        end

        row_data = data ? data.to_h : {}
        row_data[:tree_view_row_disabled] = true if row_disabled_builder&.call(item) == true
        row_data[:tree_view_row_readonly] = true if row_readonly_builder&.call(item) == true
        reason = row_disabled_reason_builder&.call(item)
        row_data[:tree_view_row_disabled_reason] = reason if reason.present?
        row_data
      end
    end

    def validate_row_status_builder!(builder, name)
      return if builder.nil? || builder.respond_to?(:call)

      raise ArgumentError, "#{name} must respond to call"
    end
  end
end

TreeView::RenderState.prepend(TreeView::RenderStateRowStatus)
