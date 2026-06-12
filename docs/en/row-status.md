# Row status

This page explains hooks for marking an entire TreeView row as disabled or readonly, with an optional disabled reason.

## Overview

Row status is a display hook for expressing node-level row state.

TreeView is responsible for:

- invoking `row_disabled_builder`, `row_readonly_builder`, and `row_disabled_reason_builder` when they are configured
- adding status classes and data attributes to rows
- merging status output with host app row class/data builders

Business rules, action blocking, authorization, and persistence remain host app responsibilities.

For a visual comparison of row-wide status cues, selection checkbox disabled state, and depth labels, see the [row status and depth label mockup](../mockups/row-status-depth-labels.html). The mockup is a static reference; this guide remains the source for API and responsibility-boundary wording.

## Basic example

Use the dedicated builders for each row-wide state. Each builder receives the row item and should return `true` only when that state applies.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_disabled_builder: ->(document) { document.archived? },
  row_readonly_builder: ->(document) { document.locked? },
  row_disabled_reason_builder: ->(document) {
    document.archived? ? "Archived documents cannot be changed" : nil
  }
)
```

A disabled row receives the `tree-view-row--disabled` class and `data-tree-view-row-disabled="true"`.

A readonly row receives the `tree-view-row--readonly` class and `data-tree-view-row-readonly="true"`.

When `row_disabled_reason_builder` returns a present value, TreeView adds `data-tree-view-row-disabled-reason` with that value. How the reason is shown to users remains host-app-owned.

## Relationship to row_class_builder and row_data_builder

TreeView merges row status output with host app `row_class_builder` and `row_data_builder` output.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_disabled_builder: ->(document) { document.archived? },
  row_readonly_builder: ->(document) { document.locked? },
  row_disabled_reason_builder: ->(document) { document.archived? ? "archived" : nil },
  row_class_builder: ->(document) { ["document-row", document.status] },
  row_data_builder: ->(document) { { document_id: document.id } }
)
```

TreeView keeps existing host app classes and data, then adds the documented TreeView status class/data keys when `row_disabled_builder` or `row_readonly_builder` returns `true`. Disabled reasons are added when `row_disabled_reason_builder` returns a present value.

`row_data_builder` is a host-app metadata hook. The public API manifest tracks the `row_data_builder` callback key as an initializer keyword and reader, but it does not make the callback's return shape or every merged row data attribute a manifest-backed schema. Keep host-app metadata under app-owned keys such as `document_id`; do not rely on overwriting TreeView-owned status keys like `tree_view_row_disabled`, `tree_view_row_readonly`, or `tree_view_row_disabled_reason`.

## Difference from selection disabled state

`selection[:disabled_builder]` disables a checkbox.

Row status expresses state for the whole row.

| Goal | API |
|---|---|
| Disable a checkbox | `selection[:disabled_builder]` |
| Show an entire row as disabled | `row_disabled_builder` |
| Show an entire row as readonly | `row_readonly_builder` |
| Attach a row-wide disabled reason | `row_disabled_reason_builder` |

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| status builder invocation | yes | provides builders |
| row class/data merge | yes | provides additional attributes |
| TreeView-owned status data keys | yes | should not treat them as app-owned metadata |
| host-app metadata keys from `row_data_builder` | preserves during merge | owns names, values, and JavaScript use |
| business rule | no | yes |
| authorization | no | yes |
| action disabling | no | yes |
| disabled reason display | no | yes |
| CSS styling | no | yes |
