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

## First things to consider

1. Decide whether the initial view really needs every node.
2. Limit initial expansion with `max_initial_depth`.
3. Limit render scope with `max_render_depth` or `max_leaf_distance`.
4. Use windowed rendering when many visible rows remain.
5. Use host-app lazy loading or server-side pagination when data-fetching volume needs to shrink.

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

Windowed rendering slices currently visible rows by offset and limit. It does not change server-side queries.

## Lazy loading

Use lazy loading when children should be loaded only as needed.

```ruby
lazy_loading: {
  enabled: true,
  loaded_keys: loaded_keys
}
```

Fetch behavior, queries, pagination, and Turbo Stream responses are host app responsibilities.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| render depth controls | yes | chooses settings |
| visible rows calculation | yes | no |
| window slicing | yes | renders controls |
| lazy loading hooks | yes | implements fetch/query |
| server-side pagination | no | yes |
| data loading strategy | no | yes |
| performance budget | signals only | yes |
