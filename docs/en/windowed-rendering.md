# Windowed Rendering

This page explains windowed rendering, an opt-in API for rendering only part of the currently visible rows.

## Overview

Windowed rendering slices currently visible rows by `offset` and `limit`.

It is useful when a large tree would otherwise render too much initial HTML, or when the host app wants to build pagination controls around visible rows.

TreeView is responsible for:

- flattening currently visible rows with `TreeView::VisibleRows`
- slicing visible rows with `TreeView::RenderWindow`
- rendering only the requested rows through `tree_view_rows(render_state, window: { offset:, limit: })`
- exposing metadata such as previous and next availability

The host app remains responsible for scroll observers, infinite scroll, URL query state, server-side pagination, and data fetching.

## Passing a window to tree_view_rows

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

This builds visible rows from the current expansion state and render scope, then renders only the first 50 rows.

## tree_view_window helper

Use `tree_view_window` when pagination metadata is needed.

```ruby
window = tree_view_window(@render_state, offset: 0, limit: 50)
```

Main metadata:

| API | Meaning |
|---|---|
| `rows` | Visible rows inside the window. |
| `offset` | Start offset. |
| `limit` | Maximum number of rows. |
| `total_count` | Visible row count before windowing. |
| `has_previous?` | Whether a previous window exists. |
| `has_next?` | Whether a next window exists. |

## Expansion state

Windowing is applied after the current expansion state and render scope are applied.

Collapsed descendants are not included in visible rows and therefore are not part of the window.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed,
  expanded_keys: expanded_keys
)
```

In this example, only rows made visible by `expanded_keys` are eligible for windowing.

## Use cases

- Reduce initial HTML size for large trees.
- Build pagination UI over visible rows.
- Combine with a host-app "load more" button.
- Use as a stepping stone before lazy loading or server-side pagination.

## Notes

Windowed rendering is not DOM virtualization.

- It does not observe scroll position.
- It does not automatically load the next window.
- It does not change server-side queries.
- It does not reduce the amount of tree data fetched by the host app.

If data-fetching volume needs to be reduced, combine this with host-app server-side pagination or lazy loading.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| visible rows calculation | yes | no |
| offset / limit slicing | yes | no |
| row rendering for a window | yes | calls helper |
| pagination controls | metadata only | renders UI |
| URL/query state | no | yes |
| infinite scroll | no | yes |
| server-side pagination | no | yes |
| data fetching | no | yes |
