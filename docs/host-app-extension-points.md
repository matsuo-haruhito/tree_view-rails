# Host app extension points

TreeView focuses on reusable tree rendering primitives.

Host applications can customize row output with these extension points:

- `row_partial`
- `row_class_builder`
- `row_data_builder`

## Row partial

`row_partial` is the main place for application-specific columns.

```ruby
TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

## Row classes and data

Use `row_class_builder` and `row_data_builder` to attach screen-specific markers.

```ruby
TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(item) { ["document-row"] },
  row_data_builder: ->(item) { { document_id: item.id } }
)
```

TreeView should not own application-specific row policies. Keep those decisions in the host application and use TreeView only for tree rendering structure.
