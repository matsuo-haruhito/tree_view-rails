# frozen_string_literal: true

module TreeView
  module RenderStateRowState
    attr_reader :current_key, :highlighted_keys

    def initialize(**options)
      tree = options.fetch(:tree)
      original_row_class_builder = options[:row_class_builder]
      @current_key = options.delete(:current_key)
      @highlighted_keys = Array(options.delete(:highlighted_keys)).freeze

      options[:row_class_builder] = build_row_class_builder(
        tree:,
        original_row_class_builder:,
        current_key: @current_key,
        highlighted_keys: @highlighted_keys
      )

      super(**options)
    end

    private

    def build_row_class_builder(tree:, original_row_class_builder:, current_key:, highlighted_keys:)
      return original_row_class_builder if current_key.nil? && highlighted_keys.empty?

      lambda do |item|
        node_key = tree.node_key_for(item)
        classes = Array(original_row_class_builder&.call(item)).flatten.compact
        classes << "is-current" if current_key == node_key
        classes << "is-highlighted" if highlighted_keys.include?(node_key)
        classes
      end
    end
  end
end

TreeView::RenderState.prepend(TreeView::RenderStateRowState)
