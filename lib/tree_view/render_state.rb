# frozen_string_literal: true

module TreeView
  class RenderState
    VALID_INITIAL_STATES = Configuration::VALID_INITIAL_STATES

    attr_reader :tree, :root_items, :row_partial, :ui_config, :initial_state

    # RenderState は「この画面ではどう描くか」を束ねる。
    def initialize(tree:, root_items:, row_partial:, ui_config:, initial_state: nil)
      @tree = tree
      @root_items = root_items
      @row_partial = row_partial
      @ui_config = ui_config
      @initial_state = normalize_initial_state(initial_state)
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
  end
end
