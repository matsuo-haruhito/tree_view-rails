# frozen_string_literal: true

module TreeView
  class RenderState
    VALID_INITIAL_STATES = Configuration::VALID_INITIAL_STATES
    VALID_INITIAL_EXPANSION_KEYS = %i[default max_depth expanded_keys].freeze
    VALID_RENDER_SCOPE_KEYS = %i[max_depth max_leaf_distance].freeze
    VALID_TOGGLE_SCOPE_KEYS = %i[max_depth_from_root max_leaf_distance].freeze

    attr_reader :tree,
                :root_items,
                :row_partial,
                :ui_config,
                :initial_state,
                :max_initial_depth,
                :max_render_depth,
                :max_leaf_distance,
                :max_toggle_depth_from_root,
                :max_toggle_leaf_distance,
                :expanded_keys,
                :row_class_builder,
                :row_data_builder

    # RenderState は「この画面ではどう描くか」を束ねる。
    def initialize(tree:,
                   root_items:,
                   row_partial:,
                   ui_config:,
                   initial_state: nil,
                   max_initial_depth: nil,
                   max_render_depth: nil,
                   max_leaf_distance: nil,
                   max_toggle_depth_from_root: nil,
                   max_toggle_leaf_distance: nil,
                   expanded_keys: nil,
                   initial_expansion: nil,
                   render_scope: nil,
                   toggle_scope: nil,
                   row_class_builder: nil,
                   row_data_builder: nil)
      initial_expansion_options = normalize_options(initial_expansion, :initial_expansion, VALID_INITIAL_EXPANSION_KEYS)
      render_scope_options = normalize_options(render_scope, :render_scope, VALID_RENDER_SCOPE_KEYS)
      toggle_scope_options = normalize_options(toggle_scope, :toggle_scope, VALID_TOGGLE_SCOPE_KEYS)

      @tree = tree
      @root_items = root_items
      @row_partial = row_partial
      @ui_config = ui_config
      @initial_state = normalize_initial_state(resolve_option(initial_state, initial_expansion_options[:default]))
      @max_initial_depth = normalize_non_negative_integer(resolve_option(max_initial_depth, initial_expansion_options[:max_depth]), :max_initial_depth)
      @max_render_depth = normalize_non_negative_integer(resolve_option(max_render_depth, render_scope_options[:max_depth]), :max_render_depth)
      @max_leaf_distance = normalize_non_negative_integer(resolve_option(max_leaf_distance, render_scope_options[:max_leaf_distance]), :max_leaf_distance)
      @max_toggle_depth_from_root = normalize_non_negative_integer(resolve_option(max_toggle_depth_from_root, toggle_scope_options[:max_depth_from_root]), :max_toggle_depth_from_root)
      @max_toggle_leaf_distance = normalize_non_negative_integer(resolve_option(max_toggle_leaf_distance, toggle_scope_options[:max_leaf_distance]), :max_toggle_leaf_distance)
      @expanded_keys = Array(resolve_option(expanded_keys, initial_expansion_options[:expanded_keys])).freeze
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

    def resolve_option(individual_value, grouped_value)
      individual_value.nil? ? grouped_value : individual_value
    end

    def normalize_options(value, name, valid_keys)
      return {} if value.nil?
      raise ArgumentError, "#{name} must respond to to_h" unless value.respond_to?(:to_h)

      options = value.to_h.transform_keys(&:to_sym)
      invalid_keys = options.keys - valid_keys
      if invalid_keys.any?
        raise ArgumentError, "#{name} contains unknown keys: #{invalid_keys.join(', ')}"
      end

      options
    end

    def normalize_initial_state(value)
      return nil if value.nil?

      normalized_value = value.to_sym
      return normalized_value if VALID_INITIAL_STATES.include?(normalized_value)

      raise ArgumentError, "initial_state must be one of: #{VALID_INITIAL_STATES.join(', ')}"
    end

    def normalize_non_negative_integer(value, name)
      return nil if value.nil?
      return value if value.is_a?(Integer) && value >= 0

      raise ArgumentError, "#{name} must be a non-negative Integer"
    end

    def validate_builder!(builder, name)
      return if builder.nil? || builder.respond_to?(:call)

      raise ArgumentError, "#{name} must respond to call"
    end
  end
end
