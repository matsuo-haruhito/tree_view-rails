# Data hook exports

TreeView exposes selected, host-authored data hooks from the JavaScript package root so host apps can build custom lazy-loading and toolbar integrations without hand-copying string literals.

These exports mirror the documented hooks already rendered by TreeView helpers. They do not change controller behavior, helper options, event payloads, or the responsibility boundary between TreeView and the host app.

## Remote state hooks

Import `TreeViewRemoteStateDataHooks` when shared JavaScript or tests need the lazy-loading row and placeholder attributes.

```js
import { TreeViewRemoteStateDataHooks } from "tree_view"

row.matches(`[${TreeViewRemoteStateDataHooks.childrenUrlAttribute}]`)
placeholder.dataset.treeRemoteState = "loaded"
```

Documented keys:

| Key | Value | Use |
|---|---|---|
| `lazyAttribute` | `data-tree-lazy` | Marks rows rendered for lazy loading. |
| `childrenUrlAttribute` | `data-tree-children-url` | Carries the host-app children endpoint URL. |
| `loadedAttribute` | `data-tree-loaded` | Carries whether the row's children have already been loaded. |
| `remoteStateAttribute` | `data-tree-remote-state` | Carries the placeholder state for loading, loaded, and error UI. |

Use the Ruby helpers `tree_children_container_dom_id`, `tree_remote_state_placeholder_dom_id`, and `tree_remote_state_placeholder_attributes` when rendering placeholder IDs and state attributes in Rails views. This JavaScript export is for host-app JavaScript and tests that need the same attribute names.

## Toolbar hooks

Import `TreeViewToolbarDataHooks` when custom toolbar markup, tests, or analytics setup need the TreeView-owned toolbar attributes.

```js
import { TreeViewToolbarDataHooks } from "tree_view"

const action = toolbar.querySelector(`[${TreeViewToolbarDataHooks.actionAttribute}="expand_all"]`)
```

Documented keys:

| Key | Value | Use |
|---|---|---|
| `toolbarAttribute` | `data-tree-view-toolbar` | Marks the toolbar container rendered or owned by TreeView integration code. |
| `actionAttribute` | `data-tree-view-toolbar-action` | Identifies a supported toolbar action. |
| `disabledAttribute` | `data-tree-view-toolbar-disabled` | Marks disabled fallback controls when no toolbar path is available. |

For action metadata, continue to use `tree_view_toolbar_supported_actions`, `tree_view_toolbar_actions`, or `tree_view_toolbar_action_metadata`. The JavaScript export only publishes stable attribute names; it does not replace the Ruby helper contract or define routes, authorization, copy, or Turbo response behavior.
