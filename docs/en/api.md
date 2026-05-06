# API reference

This page summarizes the main public APIs in TreeView.

For practical usage, see [Usage](usage.md). For examples, see [Cookbook](cookbook.md). For concepts, see [Glossary](glossary.md).

## TreeView::Tree

The central object for treating parent-child data as a tree.

### Records mode

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  id_method: :id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) },
  orphan_strategy: :ignore
)
```

| Argument | Required | Description |
|---|---:|---|
| `records:` | yes | Records to turn into a tree. |
| `parent_id_method:` | yes | Method name that returns the parent ID. |
| `id_method:` | no | Method name that returns the item's ID. Default: `:id`. |
| `sorter:` | no | Callable that orders roots and children. |
| `orphan_strategy:` | no | How records whose parent is missing from the record set are handled. |
| `validate_node_keys:` | no | Whether duplicate node keys are checked during initialization. |

### Resolver mode

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
)
```

### Adapter mode

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
)

tree = TreeView::Tree.new(adapter: adapter)
```

### Main methods

| Method | Description |
|---|---|
| `root_items(root_parent_id = nil)` | Returns root nodes. |
| `children_for(item)` | Returns children for the given node. |
| `parent_for(item)` | Returns the parent for the given node. Records mode only. |
| `ancestors_for(item)` | Returns ancestors from root to parent. Records mode only. |
| `path_for(item)` | Returns the path from root to the item. Records mode only. |
| `paths_for(items)` | Returns paths for multiple items. Records mode only. |
| `path_tree_for(items)` | Returns a `PathTree` that fills ancestors for the given items. |
| `reverse_tree_for(items)` | Returns a `ReverseTree` that walks from the given items toward roots. |
| `filtered_tree_for(items, mode:)` | Returns a filtered tree around matched items. |
| `descendant_counts` | Returns descendant counts by node key. |
| `node_key_for(item)` | Returns the key that identifies the node. |
| `sort_items(items)` | Sorts items with the configured sorter. |
| `orphan_items` | Returns records whose parent is missing from the record set. |
| `validate_unique_node_keys!` | Checks duplicate node keys. |

## TreeView::PathTree / ReverseTree

`path_tree_for(items)` builds a normal-direction tree: root -> parent -> matched item.

`reverse_tree_for(items)` builds a reverse-direction tree: matched item -> parent -> root.

| API | Direction | Use case |
|---|---|---|
| `path_tree_for(items)` | root -> parent -> matched item | Show search results inside the normal hierarchy. |
| `reverse_tree_for(items)` | matched item -> parent -> root | Start from child nodes and walk toward parents. |

## TreeView::FilteredTree

A wrapper for rendering search or filter results as a tree.

```ruby
filtered_tree = tree.filtered_tree_for(matched_items, mode: :with_ancestors)
```

| mode | Description |
|---|---|
| `:matched_only` | Include matched nodes only. |
| `:with_ancestors` | Include matched nodes and ancestors. |
| `:with_descendants` | Include matched nodes and descendants. |
| `:with_ancestors_and_descendants` | Include matched nodes, ancestors, and descendants. |

## TreeView::VisibleRows

Returns the currently visible rows from a `RenderState` as a flat array.

```ruby
visible_rows = TreeView::VisibleRows.new(
  tree: tree,
  root_items: tree.root_items,
  render_state: render_state
).to_a
```

Each row exposes values such as:

| Attribute | Description |
|---|---|
| `item` | Original node. |
| `depth` | Root-based depth. |
| `node_key` | Value from `tree.node_key_for(item)`. |
| `parent_key` | Parent row's node key. `nil` for roots. |
| `has_children?` | Whether the node has children. |
| `expanded?` | Whether the node is expanded in the current state. |

## TreeView::RenderWindow

Slices `VisibleRows` by `offset` and `limit`.

```ruby
window = TreeView::RenderWindow.new(
  rows: visible_rows,
  offset: 0,
  limit: 50
)
```

| API | Description |
|---|---|
| `rows` | Rows inside the window. |
| `offset` | Start offset. |
| `limit` | Maximum count. |
| `total_count` | Count before windowing. |
| `has_previous?` | Whether a previous window exists. |
| `has_next?` | Whether a next window exists. |

## TreeView::RenderState

Screen-level rendering state.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    max_depth: 2,
    expanded_keys: expanded_keys
  },
  render_scope: {
    max_depth: 3,
    max_leaf_distance: 2
  },
  selection: {
    enabled: true,
    visibility: :leaves
  }
)
```

| Argument | Required | Description |
|---|---:|---|
| `tree:` | yes | `TreeView::Tree`-compatible object. |
| `root_items:` | yes | Root nodes to render. |
| `row_partial:` | yes | Host app partial for business columns. |
| `ui_config:` | yes | `TreeView::UiConfig`. |
| `initial_state:` | no | `:expanded` or `:collapsed`. |
| `expanded_keys:` | no | Node keys to expand. |
| `collapsed_keys:` | no | Node keys to collapse. |
| `initial_expansion:` | no | Grouped initial expansion settings. |
| `render_scope:` | no | Grouped render scope settings. |
| `toggle_scope:` | no | Grouped toggle scope settings. |
| `selection:` | no | Grouped checkbox selection settings. |
| `lazy_loading:` | no | Grouped lazy loading settings. |
| `row_class_builder:` | no | Callable that returns row CSS classes. |
| `row_data_builder:` | no | Callable that returns row data attributes. |
| `badge_builder:` | no | Callable that returns a row badge or marker value. |
| `icon_builder:` | no | Compatibility alias for row badge or marker display; prefer `badge_builder` in new code. |
| `depth_label_builder:` | no | Callable that returns a depth label. |
| `row_status_builder:` | no | Callable that returns row state. |
| `row_event_payload_builder:` | no | Callable that returns drag/drop transfer payloads. This is transfer-specific, not a generic row event hook. |
| `persisted_state:` | no | Saved expansion state. |

For focused naming decisions, see [Public Name Decisions](public-name-decisions.md). For ARIA placement, see [Accessibility Semantics](accessibility-semantics.md).

## TreeView::UiConfig / UiConfigBuilder

Configuration for DOM IDs and path builders.

### Static

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_static
```

### Turbo

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth: depth, scope: scope) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth: depth, scope: scope) },
  load_children_path_builder: ->(item, depth, scope) { children_document_path(item, depth: depth, scope: scope) },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)
```

## TreeView::PersistedState / StateStore

APIs for saving and restoring expansion state through the host app.

```ruby
store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "documents:index"
)

persisted_state = store.load
store.save(expanded_keys: expanded_keys)
```

## Helpers

| Helper | Description |
|---|---|
| `tree_view_rows(render_state, window: nil)` | Renders TreeView rows. |
| `tree_view_window(render_state, offset:, limit:)` | Returns windowing metadata. |
| `tree_view_state_data(render_state)` | Builds root data attributes. |
| `tree_node_dom_id(item, tree:, ui_config:)` | Builds a node DOM ID. |
| `tree_selection_value(item, tree:, render_state:)` | Builds JSON for checkbox values. |
| `tree_view_breadcrumb(tree, item, ...)` | Renders breadcrumbs. |

## JavaScript entrypoint

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Main controllers:

- `tree-view-selection`
- `tree-view-transfer`
- `tree-view-remote-state`

## Related docs

- [API overview](api-overview.md)
- [Usage](usage.md)
- [Cookbook](cookbook.md)
- [Node keys](node-keys.md)
- [Tree diagnostics](tree-diagnostics.md)
- [Public API policy](../public-api.md)
