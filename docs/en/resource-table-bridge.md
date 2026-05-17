# Resource table bridge

`TreeView::ResourceTableRenderState` is a small bridge for host apps or table-oriented gems that already own column inference and table state.

It does not infer Active Record columns. That responsibility should remain with the host app or a table preferences layer. TreeView only builds the hierarchical render state.

## Basic usage

```ruby
render_state = TreeView::ResourceTableRenderState.call(
  records: @projects,
  context: view_context,
  table_key: "projects_tree",
  parent_id_method: :parent_project_id,
  table_state: table_state
)
```

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(render_state) %>
  </tbody>
</table>
```

The default row partial is `tree_view/resource_table_row`. It reads `table_state["visible_columns"]` when provided, and falls back to `columns`. `ResourceTableRenderState` passes both values to the row partial through the render state.

## Intended integration with Rails Table Preferences

A table preferences layer can infer columns from Active Record, merge saved table settings into a table state, and then pass that table state to TreeView:

```ruby
columns = RailsTablePreferences::Adapters::ActiveRecordColumns.call(model: Project)
table_state = RailsTablePreferences::TableState.call(settings: settings, columns: columns)

render_state = TreeView::ResourceTableRenderState.call(
  records: @projects,
  context: view_context,
  parent_id_method: :parent_project_id,
  table_key: "projects_tree",
  table_state: table_state,
  columns: columns
)
```

This keeps the responsibilities separate:

- Rails Table Preferences owns column inference, labels, saved table state, and preference UI.
- TreeView owns tree structure and hierarchical row rendering.
- The host app can override partials for presentation.
