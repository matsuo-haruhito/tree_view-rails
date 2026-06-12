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
      options = render_options.dup
      host_row_data_builder = options.delete(:row_data_builder)

      RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: row_partial,
        ui_config: resolved_ui_config,
        row_locals: row_locals,
        row_data_builder: row_data_builder(host_row_data_builder),
        **options
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

    def row_data_builder(host_row_data_builder = nil)
      lambda do |item, row_context = {}|
        host_row_data(item, host_row_data_builder, row_context).merge(bridge_row_data)
      end
    end

    def host_row_data(item, builder, row_context)
      return {} if builder.nil?

      data = if builder_accepts_row_context?(builder)
        builder.call(item, row_context)
      else
        builder.call(item)
      end
      return {} if data.nil?
      return data.to_h if data.respond_to?(:to_h)

      raise ArgumentError, "row_data_builder must return a Hash-like object for ResourceTableRenderState rows"
    end

    def builder_accepts_row_context?(builder)
      arity = builder_arity(builder)
      arity.nil? || arity.negative? || arity >= 2
    end

    def builder_arity(builder)
      return builder.arity if builder.respond_to?(:arity)
      return builder.method(:call).arity if builder.respond_to?(:method) && builder.respond_to?(:call)

      nil
    end

    def bridge_row_data
      {
        rails_ui_row: true,
        tree_view_resource_table_row: true,
        rails_table_preferences_table_key: table_key
      }.compact
    end
  end
end
