# frozen_string_literal: true

module TreeView
  module RenderStateStateMessages
    VALID_STATE_MESSAGE_KEYS = %i[empty hidden_builder].freeze

    attr_reader :empty_message, :hidden_message_builder

    def initialize(**options)
      state_messages = normalize_state_messages(options.delete(:state_messages))
      @empty_message = resolve_state_message_option(options.delete(:empty_message), state_messages[:empty])
      @hidden_message_builder = resolve_state_message_option(options.delete(:hidden_message_builder), state_messages[:hidden_builder])
      validate_state_message_builder!(@hidden_message_builder)

      super(**options)
    end

    private

    def normalize_state_messages(value)
      return {} if value.nil?
      raise ArgumentError, "state_messages must respond to to_h" unless value.respond_to?(:to_h)

      options = value.to_h.transform_keys(&:to_sym)
      invalid_keys = options.keys - VALID_STATE_MESSAGE_KEYS
      if invalid_keys.any?
        raise ArgumentError, "state_messages contains unknown keys: #{invalid_keys.join(', ')}"
      end

      options
    end

    def resolve_state_message_option(individual_value, grouped_value)
      individual_value.nil? ? grouped_value : individual_value
    end

    def validate_state_message_builder!(builder)
      return if builder.nil? || builder.respond_to?(:call)

      raise ArgumentError, "hidden_message_builder must respond to call"
    end
  end
end

TreeView::RenderState.prepend(TreeView::RenderStateStateMessages)
