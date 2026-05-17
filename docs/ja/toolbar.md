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

## label と class の変更

```erb
<%= tree_view_toolbar(
  @render_state,
  actions: [:expand_all],
  labels: { expand_all: "Open all" },
  class_name: "documents-toolbar",
  button_class_name: "documents-toolbar__button"
) %>
```

## 責務境界

TreeViewはtoolbar shell、action名validation、`toggle_all_path` によるlink生成だけを担います。

host appは以下を担当します。

- routes and controllers
- Turbo Stream responses
- authorization
- expanded keys の保存
- `:current_path` の意味づけ
- default class names 以上の見た目調整
