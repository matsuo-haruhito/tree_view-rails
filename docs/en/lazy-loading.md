# Lazy Loading

This page explains TreeView hooks for loading child nodes on demand.

## Overview

Lazy loading lets host apps avoid rendering every descendant in the initial HTML and load child nodes later through remote requests or user actions.

TreeView is responsible for:

- building child URLs through `load_children_path_builder`
- rendering row data for child URLs and loaded state
- rendering data/action hooks for the `tree-view-remote-state` controller
- providing a controller that reacts to loading, loaded, error, and retry events

The host app remains responsible for fetch behavior, Turbo requests, controller actions, authorization, queries, retry UI, and children pagination.

## UiConfig setup

Pass `load_children_path_builder` to `UiConfigBuilder#build`.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build(
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(state: state)
  }
)
```

`load_children_path_builder` only builds the URL.

## RenderState setup

Enable lazy loading on `RenderState`.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: loaded_keys,
    scope: "children"
  }
)
```

| option | meaning |
|---|---|
| `enabled:` | Whether lazy-loading data attributes should be rendered. |
| `loaded_keys:` | Node keys whose children are already loaded. |
| `scope:` | Optional scope value passed to path builders. |

## Minimal host-app pattern

A small lazy-loading integration usually has three host-app pieces:

1. A collection action that authorizes the parent and loads only direct children.
2. A partial Turbo Stream response that appends or replaces child rows.
3. A stable `loaded_keys` set so rows already returned by the server are marked as loaded on the next render.

Routes can stay ordinary Rails routes:

```ruby
resources :documents do
  member do
    get :children
  end
end
```

A controller action can keep query, authorization, and loaded-state policy in the host app:

```ruby
class DocumentsController < ApplicationController
  def index
    @tree = build_tree(Document.roots_for(current_user))
    @loaded_keys = []
    @render_state = build_render_state(@tree, loaded_keys: @loaded_keys)
  end

  def children
    @parent = Document.find(params[:id])
    authorize! @parent, :show?

    children = @parent.children.visible_to(current_user).order(:name, :id)
    @tree = build_tree(children)
    @loaded_keys = [TreeView.node_key("document", @parent.id)]
    @render_state = build_render_state(@tree, loaded_keys: @loaded_keys)
  end

  private

  def build_tree(records)
    TreeView::Tree.new(
      records: records,
      parent_id_method: :parent_document_id,
      id_method: :id
    )
  end

  def build_render_state(tree, loaded_keys:)
    TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "documents/tree_columns",
      ui_config: tree_ui,
      lazy_loading: {
        enabled: true,
        loaded_keys: loaded_keys
      }
    )
  end
end
```

The exact query shape is application-specific. The important boundary is that TreeView renders the hooks, while the host app decides which records the current user may see.

## Turbo Stream response pattern

Return only the subtree or placeholder region the host app owns. For example:

```erb
<%= turbo_stream.replace dom_id(@parent, :children) do %>
  <tbody id="<%= dom_id(@parent, :children) %>">
    <%= tree_view_rows(@render_state) %>
  </tbody>
<% end %>

<%= turbo_stream.replace dom_id(@parent, :remote_state) do %>
  <span id="<%= dom_id(@parent, :remote_state) %>" data-tree-remote-state="loaded">loaded</span>
<% end %>
```

If a request fails, return a host-app retry affordance instead of hiding the error in TreeView internals:

```erb
<%= turbo_stream.replace dom_id(@parent, :remote_state) do %>
  <span id="<%= dom_id(@parent, :remote_state) %>" data-tree-remote-state="error">
    Could not load children.
    <%= link_to "Retry", children_document_path(@parent, format: :turbo_stream), data: { turbo_stream: true } %>
  </span>
<% end %>
```

## Loaded, error, and retry states

Use clear state ownership:

| State | TreeView provides | Host app provides |
|---|---|---|
| not loaded | row data with child URL and `data-tree-loaded="false"` | initial query that omits unloaded descendants |
| loading | remote-state controller hook | fetch/Turbo request lifecycle and loading indicator |
| loaded | loaded-state data hook | returned child rows and updated loaded key state |
| error | error hook | error message, retry link, logging, and authorization-safe response |
| retry | retry hook | another request to the same host-app endpoint |

Do not treat lazy loading as authorization. Always authorize the parent and children endpoint on the server.

## Rendered row data

When lazy loading is enabled and `load_children_path_builder` returns a URL, a row receives data attributes similar to:

```html
<tr
  data-tree-lazy="true"
  data-tree-children-url="/documents/1/children"
  data-tree-loaded="false">
</tr>
```

## Remote state controller

When lazy loading is enabled, `tree_view_state_data(render_state)` adds the `tree-view-remote-state` controller and action hooks.

```text
tree-view:loading->tree-view-remote-state#loading
tree-view:loaded->tree-view-remote-state#loaded
tree-view:error->tree-view-remote-state#error
tree-view:retry->tree-view-remote-state#retry
```

The host app can dispatch these events according to fetch or Turbo request state.

## Children pagination

For very large child sets, implement server-side pagination in the host app.

TreeView only provides URL generation and row data hooks. Cursor, page token, limit, offset, next-page checks, and Turbo Stream content are host app responsibilities.

See [Children pagination](children-pagination.md) for details.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| child URL generation | yes | provides path builder |
| row data attributes | yes | consumes them |
| remote-state controller hooks | yes | dispatches events |
| fetching children | no | yes |
| Turbo Stream response | no | yes |
| authorization | no | yes |
| server-side pagination | no | yes |
| retry / error messaging | hook only | yes |
