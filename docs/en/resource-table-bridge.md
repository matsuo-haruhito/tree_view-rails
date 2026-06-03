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
- The host app can override partials for presentation, queries, authorization, and business behavior.

For host apps that use both a regular table and a tree-table, start here to decide what TreeView owns, then read the table preferences layer docs for column state, widths, presets, export metadata, and preference UI. Keep TreeView responsible for row hierarchy, visible row order, expansion state, and rendering hooks; keep the table layer responsible for table-wide column and preference state.

### Ownership boundary

When combining TreeView with a table preferences layer, keep the persisted state split by purpose:

| Owner | Owns | Does not own |
| --- | --- | --- |
| TreeView | row hierarchy, visible row order, expansion state, selection state, lazy-loading hooks, render hooks | column visibility, column order, column width, filters, sorts, presets |
| Table preferences layer | column key, visibility, order, width, filter, sort, preset state | node keys, row identity, expansion state, selection state |
| Host app | query execution, authorization, preload policy, business actions, partial overrides | hidden cross-gem state coupling |

Treat node keys and row DOM ids as TreeView identity. Treat `data-rails-table-preferences-column-key` as table-column identity. They may appear in the same row markup, but they should not be reused for each other.

### Empty row colspan policy

TreeView's built-in empty row uses a broad `colspan="999"` fallback because TreeView does not own or infer the host app's actual table column count. This keeps the no-root and no-results message spanning the table body when selection columns, row actions, or table-preference columns are present.

Do not treat that fallback as column ownership. The host app or table layer still owns the actual column count, captions, summaries, surrounding table layout, and any custom empty-state copy or CTA. If a screen needs exact colspan behavior, keep that in an app-owned empty row or custom partial instead of adding hidden coupling between TreeView and table column state.

For a focused visual reference that compares shared hierarchy rows across fuller and narrower visible-column sets without adding host-app table logic, see [resource-table-bridge.html](../mockups/resource-table-bridge.html).

## When to use it

For a regular TreeView integration, `TreeView::RenderState` is still the default choice.

Use `ResourceTableRenderState` when:

- you want a standard table and a tree-table to share the same column definitions or table state
- another layer such as Rails Table Preferences already decides `visible_columns`
- you want TreeView to stay responsible only for hierarchy and row rendering

## When not to use it

Avoid `ResourceTableRenderState` when:

- TreeView alone is enough for a simple tree
- you do not need column visibility settings or saved table state
- the host app already fully owns the row partial and table presentation as a separate implementation
