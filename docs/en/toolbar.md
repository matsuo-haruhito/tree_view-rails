# Toolbar helper

`tree_view_toolbar(render_state)` renders a small toolbar for tree-wide actions.

The helper is intentionally thin. It uses `render_state.ui_config.toggle_all_path(state:)` when available and otherwise renders disabled buttons. Host apps still own routes, authorization, Turbo responses, and the exact state transition behavior.

## Basic usage

```erb
<%= tree_view_toolbar(@render_state) %>
```

By default, the toolbar renders:

- `expand_all`
- `collapse_all`

If `UiConfig#toggle_all_path` is configured, each action renders as a link.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
  toggle_all_path_builder: ->(state) { documents_tree_path(state: state) }
)
```

## Actions

```erb
<%= tree_view_toolbar(
  @render_state,
  actions: [:expand_all, :collapse_all, :collapse_all_except_current_path]
) %>
```

Supported actions:

| Action | `toggle_all_path` state | Description |
|---|---|---|
| `:expand_all` | `:expanded` | Ask the host app to expand the tree. |
| `:collapse_all` | `:collapsed` | Ask the host app to collapse the tree. |
| `:collapse_all_except_current_path` | `:current_path` | Ask the host app to keep only the current path open. |

`collapse_all_except_current_path` is a host-app contract. TreeView only emits the toolbar action and state value.

## Visual reference

For a static comparison of expand-all, collapse-all, and current-path-preserving toolbar states, see [toolbar-actions.html](../mockups/toolbar-actions.html).

Use that mockup as a visual companion to this helper boundary: it highlights action affordances and the `:current_path` contract without defining routes, authorization copy, or Turbo response behavior.

## Custom labels and classes

```erb
<%= tree_view_toolbar(
  @render_state,
  actions: [:expand_all],
  labels: { expand_all: "Open all" },
  class_name: "documents-toolbar",
  button_class_name: "documents-toolbar__button"
) %>
```

## Responsibility boundary

TreeView renders the toolbar shell, validates action names, and builds links with `toggle_all_path`.

Host apps own:

- routes and controllers
- Turbo Stream responses
- authorization
- persistence of expanded keys
- semantics of `:current_path`
- visual styling beyond default class names
