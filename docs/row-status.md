# Row status

TreeView can mark an entire row as disabled or readonly while keeping the business rule in the host app.

## Basic usage

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_disabled_builder: ->(item) { item.archived? },
  row_readonly_builder: ->(item) { item.locked? },
  row_disabled_reason_builder: ->(item) { item.archived? ? "Archived" : nil }
)
```

## Output

Disabled rows receive `tree-view-row--disabled` and `data-tree-view-row-disabled="true"`.

Readonly rows receive `tree-view-row--readonly` and `data-tree-view-row-readonly="true"`.

When `row_disabled_reason_builder` returns a value, it is exposed as `data-tree-view-row-disabled-reason`.

Existing `row_class_builder` and `row_data_builder` output is preserved and combined with the row status metadata.

## Boundary

TreeView only adds row-level state markers.
Business-specific authorization, hidden rows, disabled action buttons, and API behavior remain the host app's responsibility.
