# Tree diagnostics helpers

`TreeView::Tree` and `TreeView::RenderState` provide small helper APIs for host apps that need to open search-result paths, inspect tree data quality, or validate rendered DOM identifiers during development and tests.

## expanded_keys_for

`expanded_keys_for(item_or_items)` returns unique node keys for the path from root to each given item.

```ruby
expanded_keys = tree.expanded_keys_for(current_document)
expanded_keys = tree.expanded_keys_for(matched_documents)
```

This is intended for initial expansion of current nodes or search results.
It is supported in records mode only, because it depends on parent lookup through `parent_id_method`.

## stats

`stats` returns a small summary of the reachable tree.

```ruby
tree.stats
#=> {
#     nodes: 120,
#     roots: 4,
#     leaves: 80,
#     max_depth: 6,
#     orphans: 2,
#     max_descendant_count: 42
#   }
```

The `nodes`, `roots`, `leaves`, `max_depth`, and `max_descendant_count` values are based on nodes reachable from `root_items`.
The `orphans` value is based on records mode orphan diagnostics and is independent of whether the orphan nodes are currently rendered as roots.

## orphan_report

`orphan_report` returns diagnostic entries for records whose parent id is not present in the same record set.

```ruby
tree.orphan_report
#=> [
#     { item: document, key: 10, missing_parent_id: 999 }
#   ]
```

This is useful for maintenance screens, data cleanup, and tests.
It is supported in records mode only.

## Node key uniqueness

`validate_unique_node_keys!` detects duplicated `node_key` values in the tree.

```ruby
tree.validate_unique_node_keys!
```

Use this in tests or development-only checks when a screen depends on stable node keys for expansion state, selection payloads, or DOM integration.

## DOM ID uniqueness

`TreeView::DomIdValidator` detects duplicate DOM IDs generated from a `RenderState` and its `ui_config`.

```ruby
render_state.validate_unique_dom_ids!
```

It checks the DOM IDs generated for rendered rows and TreeView-managed controls:

- node row DOM ID
- toggle cell / button DOM ID
- show button DOM ID
- selection checkbox DOM ID, when selection is enabled

The validator respects render scope options such as `max_render_depth` and `max_leaf_distance`, so it checks the rows that are renderable for that `RenderState`.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_render_depth: 2,
  selectable: true
)

render_state.validate_unique_dom_ids!
```

If a collision is found, `ArgumentError` includes the duplicated DOM ID and the node keys that produced it.

DOM ID validation is separate from node key validation. A duplicated `node_key` usually causes duplicated DOM IDs with the default `UiConfigBuilder`, but custom DOM ID builders can also create DOM ID collisions even when node keys are unique.

## Responsibility boundary

These helpers report or derive tree structure and render-identifier information.
They do not repair data, persist expansion state, or implement business-specific maintenance actions.
