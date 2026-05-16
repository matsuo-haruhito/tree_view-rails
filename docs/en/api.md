# API reference

This page summarizes the main public APIs in TreeView.

For practical usage, see [Usage](usage.md). For examples, see [Cookbook](cookbook.md). For concepts, see [Glossary](glossary.md).

## TreeView configuration

Host apps configure TreeView-wide defaults with `TreeView.configure`.

```ruby
TreeView.configure do |config|
  config.initial_state = :collapsed
  config.render_log_level = :warn
end
```

| Option | Default | Description |
|---|---|---|
| `initial_state` | `:expanded` | Global default expansion state when a screen-level `RenderState` does not override it. |
| `render_log_level` | `:warn` | Logger silence threshold used while TreeView helper-rendered partials are rendered. Set `nil` to keep Rails' normal partial render logging. |

`render_log_level` accepts `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:unknown`, `nil`, or the corresponding Ruby `Logger` level constants. See [Render log level](render-log-level.md) for details.

## TreeView errors

TreeView validation and configuration failures use a public error hierarchy rooted at `TreeView::Error`.

`TreeView::Error` inherits from `ArgumentError` for compatibility with existing host apps that already rescue TreeView validation failures as `ArgumentError`.

| Error class | Description |
|---|---|
| `TreeView::Error` | Base class for documented TreeView validation and configuration failures. |
| `TreeView::ConfigurationError` | Invalid options, invalid mode combinations, invalid builders, or unsupported configuration values. |
| `TreeView::InvalidTreeError` | Tree data cannot be treated as a valid tree. |
| `TreeView::DuplicateNodeKeyError` | Duplicate node keys are detected. |
| `TreeView::CycleDetectedError` | A parent/child cycle is detected. |
| `TreeView::InvalidRenderWindowError` | A render window receives an invalid `offset` or `limit`. |

See [Error hierarchy](errors.md) for rescue examples and compatibility guidance.

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

## TreeView::PathTreeBuilder

`PathTreeBuilder` builds generated folder nodes and record nodes from path-like record values. Use it when records expose paths but the host app does not have folder records in its database.

```ruby
builder = TreeView::PathTreeBuilder.new(
  records: documents,
  path_resolver: ->(document) { document.source_relative_path },
  label_resolver: ->(document) { document.title },
  id_resolver: ->(document) { TreeView.node_key(:document, document.id) },
  sort: { folders_first: true }
)

render_state = TreeView::RenderState.new(
  tree: builder.tree,
  root_items: builder.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

| Argument | Required | Description |
|---|---:|---|
| `records:` | yes | Source records that expose path-like values. |
| `path_resolver:` | yes | Callable returning a string path or array of path segments. |
| `label_resolver:` | no | Callable returning the record node label. |
| `id_resolver:` | no | Callable returning the record node key. Use this for stable typed keys. |
| `sorter:` | no | Custom `TreeView::Tree`-style sorter. |
| `sort:` | no | Hash options for default sorting. Supports `folders_first:`. |
| `separator:` | no | Path separator for string paths. Default: `/`. |
| `folder_key_prefix:` | no | Prefix for generated folder keys. Default: `folder`. |
| `record_key_prefix:` | no | Prefix for default record keys. Default: `record`. |

The builder exposes `nodes`, `paths`, `tree`, `root_items`, `children_for(node)`, and `node_key_for(node)`. Folder nodes are `TreeView::PathTreeBuilder::FolderNode`; record nodes are `TreeView::PathTreeBuilder::RecordNode` and keep the original record in `record`.

See [PathTreeBuilder](path-tree-builder.md) for examples and responsibility boundaries.

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
| `expanded_keys:` | no | Tree-side node keys to expand. These must match `tree.node_key_for(item)`, not UI-only DOM IDs. |
| `collapsed_keys:` | no | Tree-side node keys to collapse. These must match `tree.node_key_for(item)`, not UI-only DOM IDs. |
| `initial_expansion:` | no | Grouped initial expansion settings. Expansion keys inside this group follow the same tree-side node key rule. |
| `render_scope:` | no | Grouped render scope settings. |
| `toggle_scope:` | no | Grouped toggle scope settings. |
| `selection:` | no | Grouped checkbox selection settings. |
| `lazy_loading:` | no | Grouped lazy loading settings. |
| `row_class_builder:` | no | Callable that returns row CSS classes. |
| `row_data_builder:` | no | Callable that returns row data attributes. |
| `badge_builder:` | no | Callable that returns a row badge or marker value. |
| `icon_builder:` | no | Compatibility alias for row badge or marker display; prefer `badge_builder` in new code. |
| `depth_label_builder:` | no | Callable that returns a depth label. |
| `toggle_icons:` | no | Declarative map for toggle control icons. Supports `by_state`, `by_depth`, and `by_type`; see [Toggle icon customization](toggle-icons.md). |
| `toggle_icon_builder:` | no | Callable that returns toggle control content. Takes precedence over `toggle_icons:` when both are supplied. |
| `row_status_builder:` | no | Callable that returns row state. |
| `row_event_payload_builder:` | no | Callable that returns drag/drop transfer payloads. This is transfer-specific, not a generic row event hook. |
| `persisted_state:` | no | Saved expansion state. |

For focused naming decisions, see [Public Name Decisions](public-name-decisions.md). For ARIA placement, see [Accessibility Semantics](accessibility-semantics.md). For identifier design, see [Node keys](node-keys.md).

## TreeView::UiConfig / UiConfigBuilder

Configuration for DOM IDs, toggle mode, path builders, and optional Turbo Frame targeting.

| Builder | Mode | Description |
|---|---|---|
| `build_turbo(...)` | `:turbo` | Builds Turbo Stream expand/collapse URLs with host-app path builders. Accepts `turbo_frame:` to add `data-turbo-frame` to toggle links. |
| `build(...)` | `:turbo` | Backward-compatible alias for `build_turbo`. Accepts the same `turbo_frame:` option. |
| `build_static` | `:static` | Builds a static snapshot config with no expand/collapse URLs. |
| `build_client_side` | `:client` | Builds a browser-local expand/collapse config with no Turbo endpoints. |

`UiConfig#mode` returns `:turbo`, `:static`, or `:client`. `UiConfig#turbo_frame` returns the configured frame target or `nil`. Convenience predicates `turbo?`, `static?`, and `client?` are available.

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
).build_turbo(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth: depth, scope: scope) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth: depth, scope: scope) },
  load_children_path_builder: ->(item, depth, scope) { children_document_path(item, depth: depth, scope: scope) },
  toggle_all_path_builder: ->(state) { documents_path(state: state) },
  turbo_frame: "documents_tree"
)
```

When `turbo_frame:` is set, TreeView adds `data-turbo-frame` to Turbo toggle links. See [Turbo Frame option](turbo-frame.md) for scope and host-app responsibilities.

### Client-side

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_client_side
```

Client-side mode renders collapsed descendants inside the render scope into the initial HTML with `hidden`, then uses the bundled `tree-view-client` controller to toggle row visibility in the browser. It is intended for small to medium trees where initial HTML volume is acceptable.

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
| `tree_turbo_frame(ui:)` | Returns the configured Turbo Frame target for the resolved UI config, or `nil`. |
| `tree_selection_value(item, tree:, render_state:)` | Builds JSON for checkbox values. |
| `tree_view_breadcrumb(tree, item, ...)` | Renders breadcrumbs. |

## JavaScript entrypoint

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Main controllers:

- `tree-view-state`
- `tree-view-client`
- `tree-view-selection`
- `tree-view-transfer`
- `tree-view-remote-state`

## Related docs

- [API overview](api-overview.md)
- [Usage](usage.md)
- [Turbo Frame option](turbo-frame.md)
- [Cookbook](cookbook.md)
- [PathTreeBuilder](path-tree-builder.md)
- [Accessibility Semantics](accessibility-semantics.md)
- [Error hierarchy](errors.md)
- [Render log level](render-log-level.md)
- [Node keys](node-keys.md)
- [Tree diagnostics](tree-diagnostics.md)
- [Public API policy](public-api.md)
