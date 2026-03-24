# frozen_string_literal: true

module TreeView
  class UiConfig
    # DOM ID と path helper 周辺の UI 依存だけを受け持つ。
    attr_reader :node_dom_id_builder,
                :button_dom_id_builder,
                :show_button_dom_id_builder,
                :hide_descendants_path_builder,
                :show_descendants_path_builder,
                :toggle_all_path_builder,
                :indent_unit

    def initialize(node_dom_id_builder:,
                   button_dom_id_builder:,
                   show_button_dom_id_builder:,
                   hide_descendants_path_builder:,
                   show_descendants_path_builder:,
                   toggle_all_path_builder:,
                   indent_unit: '&ensp; &ensp; &ensp;')
      @node_dom_id_builder = node_dom_id_builder
      @button_dom_id_builder = button_dom_id_builder
      @show_button_dom_id_builder = show_button_dom_id_builder
      @hide_descendants_path_builder = hide_descendants_path_builder
      @show_descendants_path_builder = show_descendants_path_builder
      @toggle_all_path_builder = toggle_all_path_builder
      @indent_unit = indent_unit
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

    def hide_descendants_path(item, display_depth, scope: 'all')
      hide_descendants_path_builder.call(item, display_depth, scope)
    end

    def show_descendants_path(item, toggle_depth, scope: 'all')
      show_descendants_path_builder.call(item, toggle_depth, scope)
    end

    def toggle_all_path(state:)
      toggle_all_path_builder.call(state.to_sym)
    end
  end
end
