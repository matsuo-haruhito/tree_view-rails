# frozen_string_literal: true

module TreeView
  class PersistedState
    attr_reader :view_key, :expanded_keys

    def initialize(view_key:, expanded_keys: [])
      raise ArgumentError, "view_key is required" if view_key.nil? || view_key.to_s.empty?

      @view_key = view_key
      @expanded_keys = Array(expanded_keys).freeze
    end

    def self.from(value)
      return nil if value.nil?
      return value if value.is_a?(self)
      raise ArgumentError, "persisted_state must be Hash-like" unless value.respond_to?(:to_h)

      options = value.to_h.transform_keys(&:to_sym)
      new(view_key: options[:view_key], expanded_keys: options[:expanded_keys])
    end
  end
end
