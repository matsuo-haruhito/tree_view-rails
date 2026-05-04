# frozen_string_literal: true

module TreeView
  module RenderStateRowState
    CURRENT_ROW_CLASSES = ["is-current", "tree-view-row--current"].freeze
    HIGHLIGHTED_ROW_CLASSES = ["is-highlighted", "tree-view-row--highlighted"].freeze
    ROW_DISABLED_CLASSES = ["tree-view-row--disabled"].freeze
    ROW_READONLY_CLASSES = ["tree-view-row--readonly"].freeze

    attr_reader :current_key,
                :highlighted_keys,
                :row_disabled_builder,
                :row_readonly_builder,
                :row_disabled_reason_builder

    def initialize(**options)
      tree = options.fetch(:tree)
      original_row_class_builder = options[:row_class_builder]
      original_row_data_builder = options[:row_data_builder]
      @current_key = options.delete(:current_key)
      @highlighted_keys = Array(options.delete(:highlighted_keys)).freeze
      @row_disabled_builder = options.delete(:row_disabled_builder)
      @row_readonly_builder = options.delete(:row_readonly_builder)
      @row_disabled_reason_builder = options.delete(:row_disabled_reason_builder)

      validate_row_status_builder!(@row_disabled_builder, :row_disabled_builder)
      validate_row_status_builder!(@row_readonly_builder, :row_readonly_builder)
      validate_row_status_builder!(@row_disabled_reason_builder, :row_disabled_reason_builder)

      options[:row_class_builder] = build_row_class_builder(
        tree: tree,
        original_row_class_builder: original_row_class_builder,
        current_key: @current_key,
        highlighted_keys: @highlighted_keys,
        row_disabled_builder: @row_disabled_builder,
        row_readonly_builder: @row_readonly_builder
      )
      options[:row_data_builder] = build_row_data_builder(
        original_row_data_builder: original_row_data_builder,
        row_disabled_builder: @row_disabled_builder,
        row_readonly_builder: @row_readonly_builder,
        row_disabled_reason_builder: @row_disabled_reason_builder
      )

      super(**options)
    end

    private

    def build_row_class_builder(tree:, original_row_class_builder:, current_key:, highlighted_keys:, row_disabled_builder:, row_readonly_builder:)
      return original_row_class_builder if current_key.nil? && highlighted_keys.empty? && row_disabled_builder.nil? && row_readonly_builder.nil?

      lambda do |item|
        node_key = tree.node_key_for(item)
        classes = Array(original_row_class_builder&.call(item)).flatten.compact
        classes.concat(CURRENT_ROW_CLASSES) if current_key == node_key
        classes.concat(HIGHLIGHTED_ROW_CLASSES) if highlighted_keys.include?(node_key)
        classes.concat(ROW_DISABLED_CLASSES) if row_disabled_builder&.call(item) == true
        classes.concat(ROW_READONLY_CLASSES) if row_readonly_builder&.call(item) == true
        classes
      end
    end

    def build_row_data_builder(original_row_data_builder:, row_disabled_builder:, row_readonly_builder:, row_disabled_reason_builder:)
      return original_row_data_builder if row_disabled_builder.nil? && row_readonly_builder.nil? && row_disabled_reason_builder.nil?

      lambda do |item|
        data = original_row_data_builder&.call(item)
        row_data = data.respond_to?(:to_h) ? data.to_h : {}
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

TreeView::RenderState.prepend(TreeView::RenderStateRowState)
