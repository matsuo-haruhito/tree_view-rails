# Row status

This page explains hooks for marking an entire TreeView row as disabled, readonly, or another status.

## Overview

Row status is a display hook for expressing node-level row state.

TreeView is responsible for:

- invoking the row status builder
- adding status classes and data attributes to rows
- merging status output with host app row class/data builders

Business rules, action blocking, authorization, and persistence remain host app responsibilities.

## Basic example

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_status_builder: ->(document) {
    if document.archived?
      :disabled
    elsif document.locked?
      :readonly
    end
  }
)
```

## Return a hash

Return a hash-like value when multiple attributes should be controlled.

```ruby
row_status_builder = ->(document) {
  next unless document.archived?

  {
    status: :disabled,
    class: "is-archived",
    data: {
      reason: "archived"
    }
  }
}
```

## Relationship to row_class_builder and row_data_builder

Classes and data from `row_status_builder` are merged with host app `row_class_builder` and `row_data_builder` output.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_status_builder: ->(document) { document.archived? ? :disabled : nil },
  row_class_builder: ->(document) { ["document-row", document.status] },
  row_data_builder: ->(document) { { document_id: document.id } }
)
```

## Difference from selection disabled state

`selection[:disabled_builder]` disables a checkbox.

`row_status_builder` expresses state for the whole row.

| Goal | API |
|---|---|
| Disable a checkbox | `selection[:disabled_builder]` |
| Show an entire row as disabled or readonly | `row_status_builder` |

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| status builder invocation | yes | provides builder |
| row class/data merge | yes | provides additional attributes |
| business rule | no | yes |
| authorization | no | yes |
| action disabling | no | yes |
| CSS styling | no | yes |
