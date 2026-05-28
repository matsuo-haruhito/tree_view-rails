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

Windowed rendering controls HTML output only. It does not reduce host-app queries or fetched records. If the problem is data-loading volume, start with [Lazy Loading](lazy-loading.md) or [Children Pagination](children-pagination.md). If the problem is scroll-position-driven DOM virtualization, implement virtual scrolling in the host app.

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

## Visual reference

For a static side-by-side comparison of `offset` / `limit` slices, current-row anchoring, and previous or next metadata without host-app pagination behavior, see [windowed-rendering.html](../mockups/windowed-rendering.html).

Use that mockup together with the API examples on this page; the host app still owns offset persistence, pagination controls, and route/query design.

## Keep the current row inside the window

For navigation-heavy trees, the host app often wants to keep the currently selected row near the middle of the rendered window instead of always starting from offset `0`.

TreeView does not decide which row is "current". The host app owns that meaning and can derive an offset from the visible-row list before building the final `TreeView::RenderWindow`.

```ruby
visible_rows = TreeView::VisibleRows.new(
  tree: @render_state.tree,
  root_items: @render_state.root_items,
  render_state: @render_state
).to_a

limit = 50
current_key = @render_state.tree.node_key_for(current_document)
current_index = visible_rows.index { |row| row.node_key == current_key } || 0
anchored_offset = [current_index - (limit / 2), 0].max
window = TreeView::RenderWindow.new(visible_rows, offset: anchored_offset, limit: limit)
```

This pattern is useful when the host app has a current record from the route, selection state, or a server-driven navigation flow and wants to avoid dropping that row out of sight.

If expansion state, collapsed keys, or render scope change, recompute the visible rows before anchoring. Windowing is applied after those rules have already decided which rows are visible.

## Hand off offset across Turbo updates

When the host app replaces the tree through Turbo or another server-driven refresh, keep the current offset in app-owned state such as a query param, hidden field, or toolbar link.

```ruby
limit = 50
requested_offset = params.fetch(:tree_offset, 0).to_i
window = tree_view_window(@render_state, offset: requested_offset, limit: limit)

if window.empty? && requested_offset.positive?
  window = tree_view_window(@render_state, offset: window.previous_offset || 0, limit: limit)
end
```

```erb
<%= link_to "Previous", documents_path(tree_offset: window.previous_offset) if window.has_previous? %>
<%= link_to "Next", documents_path(tree_offset: window.next_offset) if window.has_next? %>
```

`tree_offset` is only an example key. The host app owns route design, param names, and which interactions must preserve the offset.

In practice, carry the same offset through the links or forms that re-render the tree, especially when expanding/collapsing nodes, changing the current record, or refreshing a Turbo Frame around the tree.

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

If data-fetching volume needs to be reduced, use [Lazy Loading](lazy-loading.md), [Children Pagination](children-pagination.md), or another host-app data-loading strategy.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| visible rows calculation | yes | no |
| offset / limit slicing | yes | no |
| row rendering for a window | yes | calls helper |
| current-row meaning | no | yes |
| current-row anchoring policy | no | yes |
| pagination controls | metadata only | renders UI |
| offset persistence across refreshes | no | yes |
| URL/query state | no | yes |
| infinite scroll | no | yes |
| virtual scroll | no | yes |
| server-side pagination | no | yes |
| data fetching | no | yes |
