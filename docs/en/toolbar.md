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

## Machine-readable contract

The toolbar action surface is also tracked in `config/public_api_manifest.yml` under `toolbar_actions`. That manifest lists the supported action names, their `toggle_all_path` states, and the documented data hooks `data-tree-view-toolbar-action` and `data-tree-view-toolbar-disabled`.

Host apps should prefer `tree_view_toolbar_supported_actions`, `tree_view_toolbar_actions`, or `tree_view_toolbar_action_metadata` when building custom toolbar markup. The manifest exists for compatibility checks and integration audits; internal constants remain implementation details.

## Visual reference

For a static comparison of expand-all, collapse-all, and current-path-preserving toolbar states, see [toolbar-actions.html](../mockups/toolbar-actions.html).

Use that mockup as a visual companion to this helper boundary: it highlights action affordances and the `:current_path` contract without defining routes, authorization copy, or Turbo response behavior.

## Custom labels, classes, and attributes

```erb
<%= tree_view_toolbar(
  @render_state,
  actions: [:expand_all],
  labels: { expand_all: "Open all" },
  class_name: "documents-toolbar",
  button_class_name: "documents-toolbar__button",
  html: {
    data: { controller: "toolbar-analytics" },
    aria: { label: "Document tree actions" }
  },
  action_html: ->(action) {
    {
      data: {
        analytics_action: action.fetch(:action),
        turbo_frame: "documents_tree"
      }
    }
  }
) %>
```

Use `html:` for additional attributes on the toolbar container. Its `class` is appended after `class_name`, and its `data` values are merged while keeping TreeView's `data-tree-view-toolbar="true"` hook.

Use `action_html:` for additional attributes on each rendered action link or disabled button. It may be a Proc that receives the action metadata hash, an action-keyed Hash such as `{ expand_all: { data: ... } }`, or a flat Hash applied to every action. Host app attributes are merged with the existing action metadata, but TreeView keeps ownership of `data-tree-view-toolbar-action` and `data-tree-view-toolbar-disabled`.

For heavier markup changes, custom authorization copy, extra controls, or a different button/link structure, keep using `tree_view_toolbar_actions` or `tree_view_toolbar_action_metadata` and render the toolbar in the host app.

## Responsibility boundary

TreeView renders the toolbar shell, validates action names, and builds links with `toggle_all_path`.

Host apps own:

- routes and controllers
- Turbo Stream responses
- authorization
- persistence of expanded keys
- semantics of `:current_path`
- analytics, test hooks, and screen-specific attributes passed through `html:` or `action_html:`
- visual styling beyond default class names
