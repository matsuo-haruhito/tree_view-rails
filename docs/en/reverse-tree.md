# ReverseTree

`TreeView::ReverseTree` renders records from a matched item back toward its ancestors. Use it when the starting point is a child record and the useful context is the path upward to its parents.

This guide covers the public `Tree#reverse_tree_for(items)` helper. It does not add resolver mode support, GraphAdapter support, breadcrumb behavior, or host-app navigation policy.

## When to use it

Use `reverse_tree_for` when the matched or selected records should be the visible roots of the rendered tree.

Typical examples:

- search results where each matching leaf should appear first
- audit or dependency views that start from a child record and explain the parent chain
- compact context panels where showing the full root-first hierarchy would hide the important match

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)

reverse_tree = tree.reverse_tree_for(@matched_documents)

render_state = TreeView::RenderState.new(
  tree: reverse_tree,
  root_items: reverse_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

The rendered direction becomes matched item -> parent -> root. The original records, node keys, sorter, row partials, and UI config still come from the same TreeView rendering pipeline.

## How it differs from related APIs

| API | Direction | Use when |
|---|---|---|
| `path_tree_for(items)` | root -> parent -> matched item | You want search or filter matches inside the normal hierarchy. |
| `reverse_tree_for(items)` | matched item -> parent -> root | You want each match to be the starting row and show its ancestors below it. |
| `PathTreeBuilder` | generated folder nodes -> record nodes | Your records expose path strings or segments, but the database does not have folder records. |
| `tree_view_breadcrumb(tree, item, ...)` | inline ancestor label trail | You need a compact path label, not a rendered tree of rows. |

`ReverseTree` is a tree wrapper for rendering rows. Breadcrumbs are a presentation helper for one path. `PathTreeBuilder` is for generated folder structures, while `ReverseTree` works from real records already present in a records-mode tree.

## Records mode requirement

`Tree#reverse_tree_for(items)` depends on `paths_for(items)`, which uses parent path helpers such as `parent_for`, `ancestors_for`, and `path_for`.

Those helpers are records-mode helpers. Build the base tree with `records:` and `parent_id_method:`:

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  id_method: :id
)
```

Do not use `reverse_tree_for` with resolver mode or adapter mode. Those modes do not have a parent-id lookup table, so TreeView cannot derive the path from a matched item back to a root.

If your data is graph-like or heterogeneous, use adapter mode for the normal tree and keep reverse-path presentation as host-app logic until an explicit API exists for that mode.

## Shared ancestors

When multiple matched records share an ancestor, `ReverseTree` attaches that ancestor only to the first reverse path that encounters it.

Example:

```text
child A -> parent -> root
child B -> parent -> root
```

The reverse tree renders `parent -> root` under `child A`, and `child B` remains a separate root without repeating the same parent rows.

This is intentional. TreeView row partials and helper-generated DOM IDs are based on the original record. Rendering the same ancestor record under multiple matched leaves would duplicate DOM IDs in the page. The first-path attachment keeps the output valid while preserving one visible ancestor chain.

If a host app needs to show the same ancestor under every match, that is a separate presentation decision. Use distinct wrapper records or host-app-owned markup so duplicate DOM IDs are not produced.

## Descendant counts in the reversed tree

`ReverseTree#descendant_counts` counts descendants inside the reversed view, not in the original root-first tree.

For a reverse path `child -> parent -> root`:

- `child` has two descendants in the reverse tree
- `parent` has one descendant
- `root` has zero descendants

This matches how TreeView render state and sorters inspect the tree object they receive. When a screen uses `reverse_tree` as its `tree`, treat descendant counts as counts for that reversed presentation.

## Responsibility boundary

TreeView owns:

- building reverse paths from records-mode parent relationships
- delegating node keys and sorting to the base tree
- avoiding duplicate ancestor DOM IDs by attaching shared ancestors once
- exposing root items, children, and descendant counts for the reversed tree

The host app owns:

- choosing which matched records are passed to `reverse_tree_for`
- loading and authorizing those records
- deciding whether the reversed view is the right presentation for the screen
- route, breadcrumb, action, and business wording around the tree

## Related docs

- [API overview](api-overview.md#path-helpers)
- [API reference: TreeView::PathTree / ReverseTree](api.md#treeviewpathtree--reversetree)
- [Breadcrumb](breadcrumb.md)
- [PathTreeBuilder](path-tree-builder.md)
- [Node keys](node-keys.md)
