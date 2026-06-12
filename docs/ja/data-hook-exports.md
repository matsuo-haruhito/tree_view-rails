# Data hook exports

TreeView は、host app が author する一部の data hook を JavaScript package root から公開します。これにより、host app 側の custom lazy-loading / toolbar integration で string literal を手で写さずに済みます。

これらの export は、既存の TreeView helper が描画している documented hook を mirror するだけです。controller behavior、helper option、event payload、TreeView と host app の責務境界は変更しません。

## Remote state hooks

共有 JavaScript や test で lazy-loading row / placeholder attribute 名が必要な場合は `TreeViewRemoteStateDataHooks` を import します。

```js
import { TreeViewRemoteStateDataHooks } from "tree_view"

row.matches(`[${TreeViewRemoteStateDataHooks.childrenUrlAttribute}]`)
placeholder.dataset.treeRemoteState = "loaded"
```

Documented key:

| Key | Value | 用途 |
|---|---|---|
| `lazyAttribute` | `data-tree-lazy` | lazy loading 用に描画された row を示します。 |
| `childrenUrlAttribute` | `data-tree-children-url` | host app の children endpoint URL を保持します。 |
| `loadedAttribute` | `data-tree-loaded` | その row の children が読み込み済みかを保持します。 |
| `remoteStateAttribute` | `data-tree-remote-state` | loading / loaded / error UI 用の placeholder state を保持します。 |

Rails view で placeholder ID や state attribute を描画する場合は、引き続き `tree_children_container_dom_id`、`tree_remote_state_placeholder_dom_id`、`tree_remote_state_placeholder_attributes` を使ってください。この JavaScript export は、同じ attribute 名を host app の JavaScript や test で参照するためのものです。

## Toolbar hooks

custom toolbar markup、test、analytics setup で TreeView-owned toolbar attribute 名が必要な場合は `TreeViewToolbarDataHooks` を import します。

```js
import { TreeViewToolbarDataHooks } from "tree_view"

const action = toolbar.querySelector(`[${TreeViewToolbarDataHooks.actionAttribute}="expand_all"]`)
```

Documented key:

| Key | Value | 用途 |
|---|---|---|
| `toolbarAttribute` | `data-tree-view-toolbar` | TreeView integration code が描画または所有する toolbar container を示します。 |
| `actionAttribute` | `data-tree-view-toolbar-action` | supported toolbar action を識別します。 |
| `disabledAttribute` | `data-tree-view-toolbar-disabled` | toolbar path がない場合の disabled fallback control を示します。 |

action metadata には、引き続き `tree_view_toolbar_supported_actions`、`tree_view_toolbar_actions`、`tree_view_toolbar_action_metadata` を使ってください。この JavaScript export は安定した attribute 名だけを公開し、Ruby helper contract の置き換えや route、authorization、copy、Turbo response behavior の定義は行いません。
