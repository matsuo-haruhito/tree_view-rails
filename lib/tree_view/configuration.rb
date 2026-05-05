# frozen_string_literal: true

module TreeView
  class Configuration
    VALID_INITIAL_STATES = %i[expanded collapsed].freeze

    attr_reader :initial_state

    # 画面ごとに未指定だった場合の既定値だけを持つ。
    def initialize(initial_state: :expanded)
      self.initial_state = initial_state
    end

    def initial_state=(value)
      @initial_state = normalize_initial_state(value)
    end

    private

    def normalize_initial_state(value)
      raise_invalid_initial_state! unless value.respond_to?(:to_sym)

      normalized_value = value.to_sym
      return normalized_value if VALID_INITIAL_STATES.include?(normalized_value)

      raise_invalid_initial_state!
    end

    def raise_invalid_initial_state!
      raise ArgumentError, "initial_state must be one of: #{VALID_INITIAL_STATES.join(", ")}"
    end
  end
end
