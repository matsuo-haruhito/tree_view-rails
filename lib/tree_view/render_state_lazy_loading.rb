# frozen_string_literal: true

module TreeView
  module RenderStateLazyLoading
    VALID_LAZY_LOADING_KEYS = %i[enabled loaded_keys scope].freeze

    attr_reader :lazy_loading_enabled,
                :lazy_loading_loaded_keys,
                :lazy_loading_scope

    def initialize(**options)
      lazy_loading_options = normalize_lazy_loading_options(options.delete(:lazy_loading))

      @lazy_loading_enabled = normalize_lazy_loading_boolean(
        resolve_lazy_loading_option(options.delete(:lazy_loading_enabled), lazy_loading_options[:enabled]),
        :lazy_loading_enabled
      )
      @lazy_loading_loaded_keys = Array(
        resolve_lazy_loading_option(options.delete(:lazy_loading_loaded_keys), lazy_loading_options[:loaded_keys])
      ).freeze
      @lazy_loading_scope = resolve_lazy_loading_option(options.delete(:lazy_loading_scope), lazy_loading_options[:scope]) || "all"

      super(**options)
    end

    def lazy_loading_enabled?
      lazy_loading_enabled == true
    end

    private

    def normalize_lazy_loading_options(value)
      return {} if value.nil?
      raise ArgumentError, "lazy_loading must respond to to_h" unless value.respond_to?(:to_h)

      options = value.to_h.transform_keys(&:to_sym)
      invalid_keys = options.keys - VALID_LAZY_LOADING_KEYS
      if invalid_keys.any?
        raise ArgumentError, "lazy_loading contains unknown keys: #{invalid_keys.join(', ')}"
      end

      options
    end

    def resolve_lazy_loading_option(individual_value, grouped_value)
      individual_value.nil? ? grouped_value : individual_value
    end

    def normalize_lazy_loading_boolean(value, name)
      return false if value.nil?
      return value if value == true || value == false

      raise ArgumentError, "#{name} must be true or false"
    end
  end
end

TreeView::RenderState.prepend(TreeView::RenderStateLazyLoading)
