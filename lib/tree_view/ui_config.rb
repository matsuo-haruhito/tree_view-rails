# frozen_string_literal: true

module TreeView
  class UiConfig
    SCOPE_FORMATS = %i[string object].freeze

    # DOM ID と path helper 周辺の UI 依存だけを受け持つ。
    attr_reader :node_dom_id_builder,
      :button_dom_id_builder,
      :show_button_dom_id_builder,
      :hide_descendants_path_builder,
      :show_descendants_path_builder,
      :load_children_path_builder,
      :toggle_all_path_builder,
      :indent_unit,
      :scope_format

    def initialize(node_dom_id_builder:,
      button_dom_id_builder:,
      show_button_dom_id_builder:,
      hide_descendants_path_builder: nil,
      show_descendants_path_builder: nil,
      load_children_path_builder: nil,
      toggle_all_path_builder: nil,
      indent_unit: "&ensp; &ensp; &ensp;",
      scope_format: :string)
      validate_builder!(node_dom_id_builder, :node_dom_id_builder)
      validate_builder!(button_dom_id_builder, :button_dom_id_builder)
      validate_builder!(show_button_dom_id_builder, :show_button_dom_id_builder)
      validate_optional_builder!(hide_descendants_path_builder, :hide_descendants_path_builder)
      validate_optional_builder!(show_descendants_path_builder, :show_descendants_path_builder)
      validate_optional_builder!(load_children_path_builder, :load_children_path_builder)
      validate_optional_builder!(toggle_all_path_builder, :toggle_all_path_builder)

      @node_dom_id_builder = node_dom_id_builder
      @button_dom_id_builder = button_dom_id_builder
      @show_button_dom_id_builder = show_button_dom_id_builder
      @hide_descendants_path_builder = hide_descendants_path_builder
      @show_descendants_path_builder = show_descendants_path_builder
      @load_children_path_builder = load_children_path_builder
      @toggle_all_path_builder = toggle_all_path_builder
      @indent_unit = indent_unit
      @scope_format = normalize_scope_format(scope_format)
    end

    def node_dom_id(item_or_id)
      node_dom_id_builder.call(item_or_id)
    end

    def button_dom_id(item_or_id)
      button_dom_id_builder.call(item_or_id)
    end

    def show_button_dom_id(item_or_id)
      show_button_dom_id_builder.call(item_or_id)
    end

    def hide_descendants_path(item, display_depth, scope: "all")
      return nil unless hide_descendants_path_builder

      hide_descendants_path_builder.call(item, display_depth, scope)
    end

    def show_descendants_path(item, toggle_depth, scope: "all")
      return nil unless show_descendants_path_builder

      show_descendants_path_builder.call(item, toggle_depth, scope)
    end

    def load_children_path(item, depth, scope: "all")
      return nil unless load_children_path_builder

      load_children_path_builder.call(item, depth, scope)
    end

    def object_scope?
      scope_format == :object
    end

    def toggle_all_path(state:)
      return nil unless toggle_all_path_builder

      toggle_all_path_builder.call(state.to_sym)
    end

    def static?
      hide_descendants_path_builder.nil? &&
        show_descendants_path_builder.nil? &&
        load_children_path_builder.nil? &&
        toggle_all_path_builder.nil?
    end

    private

    def validate_builder!(builder, name)
      return if builder.respond_to?(:call)

      raise ArgumentError, "#{name} must respond to call"
    end

    def validate_optional_builder!(builder, name)
      return if builder.nil?

      validate_builder!(builder, name)
    end

    def normalize_scope_format(value)
      raise_invalid_scope_format! unless value.respond_to?(:to_sym)

      normalized_value = value.to_sym
      return normalized_value if SCOPE_FORMATS.include?(normalized_value)

      raise_invalid_scope_format!
    end

    def raise_invalid_scope_format!
      raise ArgumentError, "scope_format must be one of: #{SCOPE_FORMATS.join(", ")}"
    end
  end
end
