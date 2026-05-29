# Toolbar helper

`tree_view_toolbar(render_state)` は、tree全体に対する操作用の小さなtoolbarを描画します。

このhelperは薄いadapterです。`render_state.ui_config.toggle_all_path(state:)` が使える場合はlinkを描画し、使えない場合はdisabled buttonを描画します。route、authorization、Turbo response、実際の状態遷移はhost app側の責務です。

## 基本例

```erb
<%= tree_view_toolbar(@render_state) %>
```

既定では以下を描画します。

- `expand_all`
- `collapse_all`

`UiConfig#toggle_all_path` が設定されている場合、各actionはlinkとして描画されます。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
  toggle_all_path_builder: ->(state) { documents_tree_path(state: state) }
)
```

## actions

```erb
<%= tree_view_toolbar(
  @render_state,
  actions: [:expand_all, :collapse_all, :collapse_all_except_current_path]
) %>
```

対応action:

| Action | `toggle_all_path` state | 説明 |
|---|---|---|
| `:expand_all` | `:expanded` | host appにtree全体の展開を依頼します。 |
| `:collapse_all` | `:collapsed` | host appにtree全体の折りたたみを依頼します。 |
| `:collapse_all_except_current_path` | `:current_path` | current path だけを開いた状態にするようhost appへ依頼します。 |

`collapse_all_except_current_path` はhost appとのcontractです。TreeViewはtoolbar actionとstate値を出すだけです。

## Visual reference

expand-all、collapse-all、current path を残す toolbar state を静的に見比べたい場合は [toolbar-actions.html](../mockups/toolbar-actions.html) を参照してください。

この mockup は、この helper の責務境界を視覚的に補うためのものです。action の見え方と `:current_path` contract を確認できますが、route、authorization copy、Turbo response behavior 自体を定義するものではありません。

## label、class、attribute の変更

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

`html:` は toolbar container に追加 attribute を渡すために使います。`class` は `class_name` の後ろに追加され、`data` は TreeView の `data-tree-view-toolbar="true"` hook を残したまま merge されます。

`action_html:` は各 action link または disabled button に追加 attribute を渡すために使います。action metadata hash を受け取る Proc、`{ expand_all: { data: ... } }` のような action-keyed Hash、または全 action に適用する flat Hash を渡せます。host app 側の attribute は既存 metadata と merge されますが、`data-tree-view-toolbar-action` と `data-tree-view-toolbar-disabled` は TreeView 側の値を維持します。

markup を大きく変える場合、独自の authorization copy を出す場合、追加 control や別の button/link 構造が必要な場合は、引き続き `tree_view_toolbar_actions` または `tree_view_toolbar_action_metadata` を使って host app 側で toolbar を描画してください。

## 責務境界

TreeViewはtoolbar shell、action名validation、`toggle_all_path` によるlink生成だけを担います。

host appは以下を担当します。

- routes and controllers
- Turbo Stream responses
- authorization
- expanded keys の保存
- `:current_path` の意味づけ
- `html:` / `action_html:` で渡す analytics、test hook、screen-specific attribute
- default class names 以上の見た目調整
