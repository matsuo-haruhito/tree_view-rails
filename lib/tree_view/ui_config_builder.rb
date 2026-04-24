# frozen_string_literal: true

module TreeView
  class UiConfigBuilder
    def initialize(context:, node_prefix: "item", key_resolver: nil)
      @context = context
      @node_prefix = node_prefix
      @key_resolver = key_resolver || ->(item_or_id) { item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id }
    end

    def build(show_descendants_path_builder:, hide_descendants_path_builder:, toggle_all_path_builder:, indent_unit: "&ensp; &ensp; &ensp;")
      UiConfig.new(
        node_dom_id_builder: ->(item_or_id) { "#{@node_prefix}_#{@key_resolver.call(item_or_id)}" },
        button_dom_id_builder: ->(item_or_id) { "#{@node_prefix}_button_box_#{@key_resolver.call(item_or_id)}" },
        show_button_dom_id_builder: ->(item_or_id) { "#{@node_prefix}_show_button_#{@key_resolver.call(item_or_id)}" },
        hide_descendants_path_builder: hide_descendants_path_builder,
        show_descendants_path_builder: show_descendants_path_builder,
        toggle_all_path_builder: toggle_all_path_builder,
        indent_unit: indent_unit
      )
    end

    def build_static(indent_unit: "&ensp; &ensp; &ensp;")
      UiConfig.new(
        node_dom_id_builder: ->(item_or_id) { "#{@node_prefix}_#{@key_resolver.call(item_or_id)}" },
        button_dom_id_builder: ->(item_or_id) { "#{@node_prefix}_button_box_#{@key_resolver.call(item_or_id)}" },
        show_button_dom_id_builder: ->(item_or_id) { "#{@node_prefix}_show_button_#{@key_resolver.call(item_or_id)}" },
        indent_unit: indent_unit
      )
    end
  end
end
