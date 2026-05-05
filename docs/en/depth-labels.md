# Depth labels

This page explains hooks for showing depth labels on TreeView rows.

## Overview

Depth labels are small visual hooks for showing a node's depth in a user-friendly way.

TreeView is responsible for:

- passing row depth through row context
- invoking `depth_label_builder`
- rendering the builder output in the row visual area

The host app decides the label text, business meaning of each depth, and CSS styling.

## Basic example

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(item, context) {
    "Level #{context.depth}"
  }
)
```

## Convert depth to business labels

```ruby
depth_label_builder = ->(_item, context) {
  case context.depth
  when 0 then "Category"
  when 1 then "Folder"
  else "Item"
  end
}
```

## Hide labels for some rows

When the builder returns `nil` or a blank string, no label is rendered.

```ruby
depth_label_builder = ->(_item, context) {
  context.depth.zero? ? "Root" : nil
}
```

## Context values

`context` contains row-specific rendering information.

Common values:

| API | Meaning |
|---|---|
| `depth` | Depth where root is 0. |
| `item` | Current item. |
| `tree` | Current tree. |
| `render_state` | Current RenderState. |

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| depth calculation | yes | no |
| builder invocation | yes | provides builder |
| label text | no | yes |
| CSS styling | no | yes |
| business meaning of depth | no | yes |
