# frozen_string_literal: true

require "logger"

module TreeView
  class Configuration
    VALID_INITIAL_STATES = %i[expanded collapsed].freeze
    VALID_RENDER_LOG_LEVELS = {
      debug: ::Logger::DEBUG,
      info: ::Logger::INFO,
      warn: ::Logger::WARN,
      error: ::Logger::ERROR,
      fatal: ::Logger::FATAL,
      unknown: ::Logger::UNKNOWN
    }.freeze

    attr_reader :initial_state, :render_log_level

    # 画面ごとに未指定だった場合の既定値だけを持つ。
    def initialize(initial_state: :expanded, render_log_level: :warn)
      self.initial_state = initial_state
      self.render_log_level = render_log_level
    end

    def initial_state=(value)
      @initial_state = normalize_initial_state(value)
    end

    def render_log_level=(value)
      @render_log_level = normalize_render_log_level(value)
    end

    private

    def normalize_initial_state(value)
      raise_invalid_initial_state! unless value.respond_to?(:to_sym)

      normalized_value = value.to_sym
      return normalized_value if VALID_INITIAL_STATES.include?(normalized_value)

      raise_invalid_initial_state!
    end

    def normalize_render_log_level(value)
      return nil if value.nil?
      return VALID_RENDER_LOG_LEVELS.key(value) if VALID_RENDER_LOG_LEVELS.value?(value)

      raise_invalid_render_log_level! unless value.respond_to?(:to_sym)

      normalized_value = value.to_sym
      return normalized_value if VALID_RENDER_LOG_LEVELS.key?(normalized_value)

      raise_invalid_render_log_level!
    end

    def raise_invalid_initial_state!
      raise ArgumentError, "initial_state must be one of: #{VALID_INITIAL_STATES.join(", ")}"
    end

    def raise_invalid_render_log_level!
      valid_values = VALID_RENDER_LOG_LEVELS.keys.join(", ")
      raise ArgumentError, "render_log_level must be nil or one of: #{valid_values}"
    end
  end
end
