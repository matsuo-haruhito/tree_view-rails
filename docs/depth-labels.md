# Depth labels

`depth_label_builder` renders an optional depth label for each row.

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
When the builder returns `nil` or a blank value, TreeView does not render the label for that row.

## Markup

The label uses the `tree-depth-label` class and is placed in the toggle cell.

## Boundary

TreeView only passes item and depth to the builder.
Business-specific level names, localization, and styling remain the host app's responsibility.
