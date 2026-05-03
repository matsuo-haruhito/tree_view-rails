# Tree diagnostics helpers

`TreeView::Tree` provides small helper APIs for host apps that need to open search-result paths or inspect tree data quality.

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

## Responsibility boundary

These helpers only report or derive tree structure information.
They do not repair data, persist expansion state, or implement business-specific maintenance actions.
