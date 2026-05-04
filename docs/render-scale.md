# Render scale

TreeView keeps the default table rendering path simple and predictable.

For large trees, prefer reducing rendered rows before adding browser-side windowing.

Recommended first steps:

- limit initial expansion with `max_initial_depth`
- limit rendered depth with `max_render_depth`
- focus near-leaf views with `max_leaf_distance`
- use `path_tree_for` for search-result style views
- use host-app pagination or lazy loading for very large child lists

A future windowed renderer should be opt-in. It should preserve stable DOM IDs, selection payloads, current row state, and Turbo Stream targets.
