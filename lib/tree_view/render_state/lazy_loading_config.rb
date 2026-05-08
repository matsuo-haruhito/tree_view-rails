# frozen_string_literal: true

module TreeView
  class RenderState
    class LazyLoadingConfig
      VALID_KEYS = %i[enabled loaded_keys scope].freeze

      attr_reader :enabled, :loaded_keys, :scope

      def initialize(enabled: nil, loaded_keys: nil, scope: nil, lazy_loading: nil)
        options = normalize_options(lazy_loading)

        @enabled = normalize_boolean(resolve_option(enabled, options[:enabled]), :lazy_loading_enabled)
        @loaded_keys = Array(resolve_option(loaded_keys, options[:loaded_keys])).freeze
        @scope = resolve_option(scope, options[:scope]) || "all"
      end

      def enabled?
        enabled == true
      end

      private

      def resolve_option(individual_value, grouped_value)
        individual_value.nil? ? grouped_value : individual_value
      end

      def normalize_options(value)
        return {} if value.nil?
        raise TreeView::ConfigurationError, "lazy_loading must respond to to_h; pass a Hash-like object with documented keys" unless value.respond_to?(:to_h)

        options = value.to_h.transform_keys(&:to_sym)
        invalid_keys = options.keys - VALID_KEYS
        if invalid_keys.any?
          raise TreeView::ConfigurationError, "lazy_loading contains unknown keys: #{invalid_keys.join(", ")}; supported keys are: #{VALID_KEYS.join(", ")}"
        end

        options
      end

      def normalize_boolean(value, name)
        return false if value.nil?
        return value if value == true || value == false

        raise TreeView::ConfigurationError, "#{name} must be true or false; pass a boolean value"
      end
    end
  end
end
