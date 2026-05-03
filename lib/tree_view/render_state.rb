# frozen_string_literal: true

module TreeView
  class RenderState
    VALID_INITIAL_STATES = Configuration::VALID_INITIAL_STATES

    attr_reader :tree,
                :root_items,
                :row_partial,
                :ui_config,
                :initial_state,
                :max_initial_depth,
                :row_class_builder,
                :row_data_builder

    # RenderState は「この画面ではどう描くか」を束ねる。
    def initialize(tree:,
                   root_items:,
                   row_partial:,
                   ui_config:,
                   initial_state: nil,
                   max_initial_depth: nil,
                   row_class_builder: nil,
                   row_data_builder: nil)
      @tree = tree
      @root_items = root_items
      @row_partial = row_partial
      @ui_config = ui_config
      @initial_state = normalize_initial_state(initial_state)
      @max_initial_depth = normalize_max_initial_depth(max_initial_depth)
      @row_class_builder = row_class_builder
      @row_data_builder = row_data_builder

      validate_builder!(row_class_builder, :row_class_builder)
      validate_builder!(row_data_builder, :row_data_builder)
    end

    # 画面固有指定があればそれを優先し、なければ global config を使う。
    def effective_initial_state
      initial_state || TreeView.configuration.initial_state
    end

    private

    def normalize_initial_state(value)
      return nil if value.nil?

      normalized_value = value.to_sym
      return normalized_value if VALID_INITIAL_STATES.include?(normalized_value)

      raise ArgumentError, "initial_state must be one of: #{VALID_INITIAL_STATES.join(', ')}"
    end

    def normalize_max_initial_depth(value)
      return nil if value.nil?
      return value if value.is_a?(Integer) && value >= 0

      raise ArgumentError, "max_initial_depth must be a non-negative Integer"
    end

    def validate_builder!(builder, name)
      return if builder.nil? || builder.respond_to?(:call)

      raise ArgumentError, "#{name} must respond to call"
    end
  end
end
