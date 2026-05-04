# Render scale

TreeView keeps the default table rendering path simple and predictable.

For large trees, prefer reducing rendered rows before adding browser-side windowing.

Recommended first steps:

- limit initial expansion with `max_initial_depth`
- limit rendered depth with `max_render_depth`
- focus near-leaf views with `max_leaf_distance`
- use `path_tree_for` for search-result style views
- use host-app pagination or lazy loading for very large child lists
- use `TreeView::VisibleRows` when the host app needs a flattened visible-row model for custom windowing or inspection

TreeView now exposes `TreeView::VisibleRows` as groundwork for host-app-side windowing. DOM virtualization itself is not part of the gem's default renderer; if a host app adds it, stable DOM IDs, selection payloads, current row state, and Turbo Stream targets should be preserved.
