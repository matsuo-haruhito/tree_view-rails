# Host app extension points

TreeView focuses on reusable tree rendering primitives.

Host applications can customize row output with these extension points:

- `row_partial`
- `row_class_builder`
- `row_data_builder`
- `current_key`
- `highlighted_keys`

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

## Current and highlighted rows

Use `current_key` when one row represents the currently displayed page or selected node.
Use `highlighted_keys` when one or more rows should be emphasized, such as search hits.

```ruby
TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  current_key: tree.node_key_for(current_document),
  highlighted_keys: matched_documents.map { |document| tree.node_key_for(document) },
  row_class_builder: ->(item) { ["document-row"] }
)
```

Current rows receive these classes:

- `is-current`
- `tree-view-row--current`

Highlighted rows receive these classes:

- `is-highlighted`
- `tree-view-row--highlighted`

`row_class_builder` classes are preserved and combined with TreeView's current/highlighted row classes.
Current rows also receive `aria-current="page"` so assistive technologies can identify the active row.
