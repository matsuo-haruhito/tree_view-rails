# frozen_string_literal: true

module TreeView
  class RenderState
    class SelectionConfig
      VALID_KEYS = %i[enabled visibility payload_builder checkbox_name disabled_builder disabled_reason_builder selected_keys cascade indeterminate max_count].freeze
      VALID_VISIBILITIES = %i[all roots leaves none].freeze

      attr_reader :enabled,
        :visibility,
        :payload_builder,
        :checkbox_name,
        :disabled_builder,
        :disabled_reason_builder,
        :selected_keys,
        :cascade,
        :indeterminate,
        :max_count

      def initialize(default_checkbox_name:,
        selectable: nil,
        payload_builder: nil,
        checkbox_name: nil,
        disabled_builder: nil,
        disabled_reason_builder: nil,
        selected_keys: nil,
        cascade: nil,
        indeterminate: nil,
        max_count: nil,
        selection: nil)
        options = normalize_options(selection)

        @enabled = normalize_boolean(resolve_option(selectable, options[:enabled]), :selectable)
        @visibility = normalize_visibility(options[:visibility])
        @payload_builder = resolve_option(payload_builder, options[:payload_builder])
        @checkbox_name = resolve_option(checkbox_name, options[:checkbox_name]) || default_checkbox_name
        @disabled_builder = resolve_option(disabled_builder, options[:disabled_builder])
        @disabled_reason_builder = resolve_option(disabled_reason_builder, options[:disabled_reason_builder])
        @selected_keys = Array(resolve_option(selected_keys, options[:selected_keys])).freeze
        @cascade = normalize_boolean(resolve_option(cascade, options[:cascade]), :selection_cascade)
        @indeterminate = normalize_boolean(resolve_option(indeterminate, options[:indeterminate]), :selection_indeterminate)
        @max_count = normalize_optional_positive_integer(resolve_option(max_count, options[:max_count]), :selection_max_count)
      end

      def enabled?
        enabled == true
      end

      def cascade?
        cascade == true
      end

      def indeterminate?
        indeterminate == true
      end

      private

      def resolve_option(individual_value, grouped_value)
        individual_value.nil? ? grouped_value : individual_value
      end

      def normalize_options(value)
        return {} if value.nil?
        raise TreeView::ConfigurationError, "selection must respond to to_h; pass a Hash-like object with documented keys" unless value.respond_to?(:to_h)

        options = value.to_h.transform_keys(&:to_sym)
        invalid_keys = options.keys - VALID_KEYS
        if invalid_keys.any?
          raise TreeView::ConfigurationError, "selection contains unknown keys: #{invalid_keys.join(", ")}; supported keys are: #{VALID_KEYS.join(", ")}"
        end

        options
      end

      def normalize_visibility(value)
        return :all if value.nil?
        raise_invalid_visibility! unless value.respond_to?(:to_sym)

        normalized_value = value.to_sym
        return normalized_value if VALID_VISIBILITIES.include?(normalized_value)

        raise_invalid_visibility!
      end

      def raise_invalid_visibility!
        raise TreeView::ConfigurationError, "selection visibility must be one of: #{VALID_VISIBILITIES.join(", ")}; choose which rows should show checkboxes"
      end

      def normalize_boolean(value, name)
        return false if value.nil?
        return value if value == true || value == false

        raise TreeView::ConfigurationError, "#{name} must be true or false; pass a boolean value"
      end

      def normalize_optional_positive_integer(value, name)
        return nil if value.nil?
        return value if value.is_a?(Integer) && value.positive?

        raise TreeView::ConfigurationError, "#{name} must be a positive Integer; pass nil or a value greater than 0"
      end
    end
  end
end
