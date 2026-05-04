# frozen_string_literal: true

module TreeView
  class PersistedState
    attr_reader :tree_instance_key, :expanded_keys

    def initialize(tree_instance_key:, expanded_keys: [])
      raise ArgumentError, "tree_instance_key is required" if tree_instance_key.nil? || tree_instance_key.to_s.empty?

      @tree_instance_key = tree_instance_key
      @expanded_keys = Array(expanded_keys).freeze
    end

    def self.from(value)
      return nil if value.nil?
      return value if value.is_a?(self)
      raise ArgumentError, "persisted_state must be Hash-like" unless value.respond_to?(:to_h)

      options = value.to_h.transform_keys(&:to_sym)
      new(tree_instance_key: options[:tree_instance_key], expanded_keys: options[:expanded_keys])
    end
  end
end
