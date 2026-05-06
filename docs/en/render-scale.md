# Render scale

This page explains rendering volume, HTML size, and responsibility boundaries for large trees.

## Overview

TreeView provides several rendering controls for large trees.

- `max_initial_depth`
- `max_render_depth`
- `max_leaf_distance`
- `TreeView::VisibleRows`
- `TreeView::RenderWindow`
- lazy loading hooks

TreeView does not control host-app server-side queries or the amount of data fetched.

`TreeView::RenderWindow` is an HTML-output control. Even though it accepts `offset` and `limit`, it slices rows that are already visible in the current render state. It is not a server-side pagination API, a database query optimizer, or a built-in virtual scrolling solution.

## First things to consider

1. Decide whether the initial view really needs every node.
2. Limit initial expansion with `max_initial_depth`.
3. Limit render scope with `max_render_depth` or `max_leaf_distance`.
4. Use windowed rendering when many visible rows remain and you only need to reduce HTML output.
5. Use lazy loading when children should not be fetched or rendered until the user asks for them.
6. Use children pagination when one parent can have many children and each request should fetch only a page.
7. Add host-app virtual scrolling when scroll-position-driven DOM virtualization is required.

## Decision table

| Goal | Start with | What it reduces | Boundary |
|---|---|---|---|
| Reduce initial expansion | `max_initial_depth` | Rows opened on first paint | Does not reduce database records by itself. |
| Limit rendered depth | `max_render_depth` / `max_leaf_distance` | Descendants eligible for HTML rendering | Host app must also scope queries if query volume matters. |
| Render a slice of visible rows | `TreeView::RenderWindow` / `tree_view_rows(..., window:)` | HTML output for currently visible rows | Does not reduce host-app queries or fetched records. |
| Reduce child fetching | [Lazy Loading](lazy-loading.md) | Up-front child fetching and unloaded-child HTML | Host app implements fetch, queries, and responses. |
| Page many children | [Children Pagination](children-pagination.md) | Children fetched per request | Host app owns cursor, offset, limit, next-page checks, and query strategy. |
| Full virtual scroll | Host app JavaScript | DOM work based on scroll position | Outside TreeView's built-in scope. |

## Limit initial expansion

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_initial_depth: 1
)
```

## Limit render scope

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  render_scope: {
    max_depth: 3,
    max_leaf_distance: 2
  }
)
```

## Windowed rendering

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

Windowed rendering slices currently visible rows by offset and limit. It limits how many rows are emitted as HTML from the visible-row list that TreeView has already computed.

Windowed rendering does not:

- change host-app server-side queries
- reduce records fetched from the database
- page children for a parent
- observe scroll position
- implement DOM virtualization or infinite scroll

Use it when the tree data is already available but emitting every currently visible row would create too much HTML. If data-fetching volume needs to shrink, use [Lazy Loading](lazy-loading.md) or [Children Pagination](children-pagination.md) in the host app. If the product needs scroll-position-driven virtualization, implement that in the host app.

## Lazy loading

Use lazy loading when children should be loaded only as needed.

```ruby
lazy_loading: {
  enabled: true,
  loaded_keys: loaded_keys
}
```

TreeView renders child URL and row-state hooks. Fetch behavior, queries, pagination, and Turbo Stream responses are host app responsibilities. See [Lazy Loading](lazy-loading.md) for details.

## Children pagination

Use children pagination when a parent can have many children and the host app should fetch them in smaller pages.

TreeView does not choose cursor, offset, limit, ordering, next-page detection, or response shape. It provides integration boundaries through lazy-loading URLs and row data hooks. See [Children Pagination](children-pagination.md) for details.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| render depth controls | yes | chooses settings |
| visible rows calculation | yes | no |
| window slicing | yes | renders controls |
| lazy loading hooks | yes | implements fetch/query |
| children pagination algorithm | no | yes |
| server-side pagination | no | yes |
| data loading strategy | no | yes |
| infinite scroll / virtual scroll | no | yes |
| performance budget | signals only | yes |
