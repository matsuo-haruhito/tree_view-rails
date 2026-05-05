# API overview

This page gives an overview of the main public APIs. See [API reference](../api.md) for the full detailed reference.

## Core objects

| API | Description |
|---|---|
| `TreeView::Tree` | Builds and queries tree structures from records, resolvers, or adapters. |
| `TreeView::RenderState` | Holds screen-level rendering state such as roots, row partial, UI config, expansion, selection, and render scope. |
| `TreeView::UiConfig` | Stores DOM ID and path-building behavior for static or Turbo rendering. |
| `TreeView::UiConfigBuilder` | Builds `UiConfig` objects from a Rails view context. |
| `TreeView::VisibleRows` | Flattens currently visible rows from a render state. |
| `TreeView::RenderWindow` | Slices visible rows by `offset` and `limit` and exposes pagination metadata. |
| `TreeView::PersistedState` | Represents persisted expansion state. |
| `TreeView::StateStore` | Loads and saves persisted state through a host app model. |

## Tree construction

### records mode

Use records mode when each item has an ID and a parent ID.

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)
```

Important options:

| Option | Description |
|---|---|
| `records:` | Items to render as a tree. |
| `parent_id_method:` | Method name that returns the parent ID. |
| `id_method:` | Method name that returns the item ID. Defaults to `:id`. |
| `sorter:` | Callable used for root and child ordering. |
| `orphan_strategy:` | Strategy for records whose parent is missing from the record set. |

### resolver mode

Use resolver mode when children come from a callable instead of parent IDs.

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)
```

### adapter mode

Use adapter mode for heterogeneous or graph-like structures.

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)

tree = TreeView::Tree.new(adapter: adapter)
```

## Rendering

The recommended rendering entrypoint is `tree_view_rows(render_state)`.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

```erb
<tbody>
  <%= tree_view_rows(@render_state) %>
</tbody>
```

For windowed rendering, pass a window hash:

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

For pagination metadata, use `tree_view_window`:

```ruby
window = tree_view_window(@render_state, offset: 0, limit: 50)
window.has_next?
```

## RenderState option groups

`RenderState` accepts both legacy flat keyword options and grouped options.

| Group | Description |
|---|---|
| `initial_expansion:` | Default expansion, max initial depth, expanded keys, and collapsed keys. |
| `render_scope:` | Depth and leaf-distance limits for what is rendered. |
| `toggle_scope:` | Depth and leaf-distance limits passed to toggle path builders. |
| `selection:` | Checkbox selection behavior and payload options. |
| `lazy_loading:` | Remote children state and scope options. |

Flat keyword options take precedence when both forms are provided.

## Selection

TreeView can render checkbox selection, but the host app owns the business action.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    visibility: :leaves
  }
)
```

Use `TreeView.parse_selection_params` to parse submitted JSON values when appropriate.

## Path helpers

Records mode provides helpers for inspecting parent paths.

| API | Description |
|---|---|
| `parent_for(item)` | Returns the parent item. |
| `ancestors_for(item)` | Returns ancestors from root to parent. |
| `path_for(item)` | Returns the path from root to item. |
| `paths_for(items)` | Returns paths for multiple items. |
| `path_tree_for(items)` | Builds a root-to-match `PathTree`. |
| `reverse_tree_for(items)` | Builds a match-to-root `ReverseTree`. |

## Public helper entrypoints

| Helper | Description |
|---|---|
| `tree_view_rows` | Render TreeView rows from a render state. |
| `tree_view_window` | Build a render window and expose metadata. |
| `tree_node_dom_id` | Build a node DOM ID through `UiConfig`. |
| `tree_selection_value` | Build a JSON checkbox value. |
| `tree_view_breadcrumb` | Render an ancestor breadcrumb. |

## JavaScript entrypoint

The public JavaScript entrypoint is `tree_view/index.js`.

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Exported controller classes are documented as the stable entrypoints. Individual controller file layout is internal.

## More detail

- Full API reference: [api.md](../api.md)
- Public API compatibility policy: [public-api.md](../public-api.md)
- Minimal usage: [minimal-usage.md](minimal-usage.md)
- Main usage guide: [usage.md](usage.md)
