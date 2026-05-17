# frozen_string_literal: true

module TreeView
  class ResourceTableRenderState
    DEFAULT_ROW_PARTIAL = "tree_view/resource_table_row"

    def self.call(records:, context:, row_partial: DEFAULT_ROW_PARTIAL, parent_id_method: :parent_id, id_method: :id, table_key: nil, columns: nil, table_state: nil, ui_config: nil, **render_options)
      new(
        records: records,
        context: context,
        row_partial: row_partial,
        parent_id_method: parent_id_method,
        id_method: id_method,
        table_key: table_key,
        columns: columns,
        table_state: table_state,
        ui_config: ui_config,
        render_options: render_options
      ).call
    end

    def initialize(records:, context:, row_partial:, parent_id_method:, id_method:, table_key:, columns:, table_state:, ui_config:, render_options: {})
      @records = records
      @context = context
      @row_partial = row_partial
      @parent_id_method = parent_id_method
      @id_method = id_method
      @table_key = table_key
      @columns = columns
      @table_state = table_state
      @ui_config = ui_config
      @render_options = render_options
    end

    def call
      RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: row_partial,
        ui_config: resolved_ui_config,
        row_locals: row_locals,
        row_data_builder: row_data_builder,
        **render_options
      )
    end

    private

    attr_reader :records,
      :context,
      :row_partial,
      :parent_id_method,
      :id_method,
      :table_key,
      :columns,
      :table_state,
      :ui_config,
      :render_options

    def tree
      @tree ||= Tree.new(
        records: records,
        id_method: id_method,
        parent_id_method: parent_id_method
      )
    end

    def resolved_ui_config
      ui_config || UiConfigBuilder.new(
        context: context,
        node_prefix: table_key || "tree-resource"
      ).build_static
    end

    def row_locals
      {
        columns: columns,
        table_state: table_state
      }.compact
    end

    def row_data_builder
      lambda do |_item, _row_context = {}|
        {
          rails_ui_row: true,
          tree_view_resource_table_row: true,
          rails_table_preferences_table_key: table_key
        }.compact
      end
    end
  end
end