# Depth labels

`depth_label_builder` optionally renders a small depth label cell for each row.

Use it when the depth itself has user-facing meaning, such as level names, hierarchy numbers, or root/child labels.

## Basic usage

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(_item, depth) { "Level " + (depth + 1).to_s }
)
```

The builder receives `item` and zero-based `depth`.
When the builder returns `nil` or a blank value, TreeView does not render the depth label cell for that row.

## Markup

Rows with a depth label receive an extra cell before the host app `row_partial` output.
The cell uses `tree-depth-label-cell`, and the label uses `tree-depth-label`.

## Responsibility boundary

TreeView only passes item/depth to the builder and renders the returned label.
Business-specific level names, localization, and styling remain the host app's responsibility.
