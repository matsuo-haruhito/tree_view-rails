# Usage

This page explains the main ways to render TreeView rows in a Rails host app.

During the migration to language-specific docs, the detailed legacy guide remains available at [root usage guide](../usage.md).

## Basic flow

The usual flow is:

1. Build a `TreeView::Tree` from records, resolver data, or an adapter.
2. Build a `TreeView::UiConfig` with `TreeView::UiConfigBuilder`.
3. Build a `TreeView::RenderState` for the screen.
4. Render rows with `tree_view_rows(@render_state)`.
5. Put host-app-specific columns in the configured `row_partial`.

TreeView renders the tree UI primitives. Host apps remain responsible for application-specific CRUD, authorization, persistence, server-side queries, Turbo Stream responses, and business actions.

## Toggle modes

Choose the toggle mode per tree instance. One host app can use different modes on different screens, or even render multiple trees with different modes on the same page.

| Builder | Mode | Behavior |
|---|---|---|
| `build_turbo` / `build` | `:turbo` | Expand/collapse through host-app Turbo Stream endpoints. |
| `build_static` | `:static` | Render a static snapshot. Collapsed descendants are not rendered and cannot be opened in the browser. |
| `build_client_side` | `:client` | Render descendants into the initial HTML and use TreeView JavaScript to show/hide rows in the browser. |

## Static rendering

Use `build_static` when you want static tree rows without expand/collapse URLs.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_static
```

## Turbo Stream expand/collapse

Use `build_turbo` with path builders when the host app handles expand/collapse through Turbo Stream endpoints. `build` is kept as a backward-compatible alias for `build_turbo`.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(state: state)
  }
)
```

Path builders only build URLs. The host app owns controller actions, Turbo Stream responses, authorization, and server-side queries.

## Client-side expand/collapse

Use `build_client_side` when all nodes in the render scope can be included in the initial HTML and you only need browser-local expand/collapse.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_client_side

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

In client-side mode, collapsed descendants inside `max_render_depth` / `max_leaf_distance` are still rendered into the initial HTML with the `hidden` attribute. The bundled `tree-view-client` controller toggles `hidden`, `aria-expanded`, and TreeView row state data inside the current tree element. It does not replace lazy loading, children pagination, authorization, or server-side query strategies for large trees.

Register TreeView JavaScript controllers as usual:

```js
import { application } from "controllers/application"
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Render the controller data on the tree root element:

```erb
<table class="tree-view-table" data: tree_view_state_data(@render_state)>
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

Client-side mode uses one toggle button icon for both open and closed states. If you want a visual state change, style the button from `aria-expanded` in the host app CSS:

```css
.tree-toggle__client-action[aria-expanded="false"] .tree-toggle__client-icon::before {
  content: "▶";
}

.tree-toggle__client-action[aria-expanded="true"] .tree-toggle__client-icon::before {
  content: "▼";
}
```

## Regular tree

Use records mode when your items have parent-child relationships.

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)
```

Use `sorter:` to customize ordering.

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)
```

For stable multi-key sorting, return an array from `sort_by`.

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by do |node|
    [
      node.display_order || Float::INFINITY,
      node.name.to_s,
      node.id
    ]
  end
}
```

## RenderState

`TreeView::RenderState` holds screen-level rendering state.

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

`initial_state` is optional. When omitted, TreeView falls back to global config, then to `:expanded`.

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

For windowed rendering, pass `window:`.

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

## Row partial

Host-app-specific columns live in the configured `row_partial`.

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

The partial receives `item`.

Use `row_actions_partial` for per-row action links/buttons such as Edit, Show, Delete, Archive, and other host-app actions. For display columns, action links, inline controls, depth labels, badges, icons, and status markers, see [Cookbook: Row customization quick guide](cookbook.md#row-customization-quick-guide).

## Interactive controls inside rows

Host apps can place inputs, selects, textareas, buttons, links, and `contenteditable` labels inside `row_partial` or `row_actions_partial`. TreeView treats these native interactive elements as application-owned controls, so tree keyboard navigation and transfer drag start behavior ignore events that originate from them.

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
</td>
```

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td>
  <%= link_to "Edit", edit_document_path(item) %>
  <%= button_to "Archive", archive_document_path(item), method: :post %>
</td>
```

For custom widgets that are not native controls, add `data-tree-view-interactive="true"` to the widget or an ancestor inside the row.

```erb
<td>
  <span data-tree-view-interactive="true" contenteditable="true"><%= item.name %></span>
</td>
```

Use narrower markers when only one tree behavior should ignore the control:

- `data-tree-view-ignore-keyboard="true"` prevents arrow, space, and enter keys from triggering TreeView keyboard navigation.
- `data-tree-view-ignore-row-click="true"` is reserved for row-click integrations in host apps.
- `data-tree-view-ignore-drag="true"` prevents TreeView transfer drag start from that control.

These markers only opt a control out of TreeView behavior. Validation, persistence, authorization, CRUD routes, and inline editing flows still belong to the host app.

## Grouped options

Initial expansion, render scope, and toggle scope can be configured with grouped options.

```ruby
@render_state = TreeView::RenderState.new(
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
  toggle_scope: {
    max_depth_from_root: 2,
    max_leaf_distance: 1
  }
)
```

When both flat keyword options and grouped options are provided, flat keyword options take precedence for backward compatibility.

## Selection

Use `selection:` to enable checkbox selection.

```ruby
@render_state = TreeView::RenderState.new(
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

TreeView renders checkboxes, builds payloads, and provides a JavaScript controller for collecting selected payloads. The host app owns business actions such as deleting, moving, or relating selected nodes.

See [Selection](selection.md) for details.

## Lazy loading

Use `load_children_path_builder` and `RenderState#lazy_loading` when children are loaded on demand.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth:, scope:) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth:, scope:) },
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: loaded_keys
  }
)
```

The host app owns fetch behavior, Turbo requests, retry behavior, loading messages, and authorization.

## PathTree / ReverseTree

Use `path_tree_for` when search results should be shown with their ancestors.

```ruby
path_tree = base_tree.path_tree_for(matched_documents)
```

Use `reverse_tree_for` when the UI starts at matched child nodes and walks toward roots.

```ruby
reverse_tree = base_tree.reverse_tree_for(matched_documents)
```

| API | Direction | Use case |
|---|---|---|
| `path_tree_for(items)` | root -> parent -> matched item | Show search results inside the normal hierarchy |
| `reverse_tree_for(items)` | matched item -> parent -> root | Walk from child nodes toward parents |

## Next steps

- [API overview](api-overview.md)
- [API reference](api.md)
- [Cookbook: Row customization quick guide](cookbook.md#row-customization-quick-guide)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)
