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

The toolbar action/state mapping is tracked in `config/public_api_manifest.yml` under `toolbar_actions`. The manifest maps each supported action name to the `toggle_all_path` state value used by the helper.

The metadata returned by `tree_view_toolbar_action_metadata` is also tracked under `toolbar_action_metadata`. Its public key set is `action`, `state`, `label`, `path`, `disabled`, and `data`. The TreeView-owned `data` keys are `tree_view_toolbar_action` and, for disabled fallback controls, `tree_view_toolbar_disabled`.

When `toggle_all_path` is unavailable, metadata returns `path: nil`, `disabled: true`, and the disabled data hook so host-app-owned toolbar markup can render a disabled fallback without inventing a route. Authorization, route availability, and final fallback copy still belong to the host app.

Host apps should prefer `tree_view_toolbar_supported_actions`, `tree_view_toolbar_actions`, or `tree_view_toolbar_action_metadata` when building custom toolbar markup. The manifest exists for compatibility checks and integration audits; internal constants remain implementation details.

## Visual reference

For a static comparison of expand-all, collapse-all, and current-path-preserving toolbar states, see [toolbar-actions.html](../mockups/toolbar-actions.html).

Use that mockup as a visual companion to this helper boundary: it highlights action affordances and the `:current_path` contract without defining routes, authorization copy, or Turbo response behavior.

When reviewing `html:` or `action_html:` attributes, also read the [Toolbar action HTML boundary note](../toolbar_action_html_boundary.md). The mockup shows visual states, while the boundary note focuses on attribute ownership: TreeView-owned hooks stay present, and analytics, Turbo targets, screen-specific grouping, and final copy remain host-app responsibilities.

## Label resolution

`tree_view_toolbar`, `tree_view_toolbar_actions`, and `tree_view_toolbar_action_metadata` resolve action labels in this order:

1. An explicit `labels:` entry for the action, such as `{ expand_all: "Open all" }`.
2. The current locale's `tree_view.toolbar.labels.*` translation.
3. TreeView's built-in English fallback label.

Supported translation keys are:

```yml
tree_view:
  toolbar:
    labels:
      expand_all: "Expand all"
      collapse_all: "Collapse all"
      collapse_all_except_current_path: "Collapse all except current path"
```

Use locale files for the host app's usual toolbar wording. Use `labels:` only for screen-specific copy that should override the locale default. TreeView provides the keys and fallback labels; the host app still owns final wording, locale-file policy, and any product-specific terminology.

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

`actions:`, `labels:`, `class_name:`, `button_class_name:`, `html:`, and `action_html:` are tracked as the `tree_view_toolbar` helper option key set in `config/public_api_manifest.yml`. That option-key contract is separate from the `toolbar_actions` action-to-state map, which tracks supported action names and their `toggle_all_path` state values, and from `toolbar_action_metadata`, which tracks the returned metadata hash shape.

For heavier markup changes, custom authorization copy, extra controls, or a different button/link structure, keep using `tree_view_toolbar_actions` or `tree_view_toolbar_action_metadata` and render the toolbar in the host app.

## Responsibility boundary

TreeView renders the toolbar shell, validates action names, and builds links with `toggle_all_path`.

Host apps own:

- routes and controllers
- Turbo Stream responses
- authorization
- persistence of expanded keys
- semantics of `:current_path`
- final labels, locale files, and screen-specific wording passed through `labels:`
- analytics, test hooks, and screen-specific attributes passed through `html:` or `action_html:`
- visual styling beyond default class names
