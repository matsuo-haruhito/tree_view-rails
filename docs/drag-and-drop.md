# Drag and drop events

`tree_view` は、行同士のドラッグ&ドロップで host app が使いやすいpayloadと標準イベントを提供します。

DB上の親子関係更新、並び順保存、業務固有のdrop可否判定は host app 側の責務です。`tree_view` は行payload、DOM data属性、ブラウザ標準drag/dropイベントの橋渡しだけを担当します。

## 基本形

`RenderState` に `row_event_payload_builder` を指定すると、各行にdrag/drop用のdata属性とactionが付与されます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "items/tree_columns",
  ui_config: tree_ui,
  row_event_payload_builder: ->(item) {
    {
      key: tree.node_key_for(item),
      id: item.id,
      type: item.class.name
    }
  }
)
```

root要素側には `tree_view_state_data(render_state)` を指定します。`row_event_payload_builder` がある場合、`tree-view-transfer` controller も自動で含まれます。

```erb
<table data-controller="tree-view-state tree-view-transfer">
  <tbody>
    <%= tree_view_rows(render_state) %>
  </tbody>
</table>
```

helperを使う場合は以下のようにできます。

```erb
<table data-<%= tag.attributes(tree_view_state_data(render_state)) %>>
  <tbody>
    <%= tree_view_rows(render_state) %>
  </tbody>
</table>
```

## Row attributes

`row_event_payload_builder` を指定した行には、以下が付与されます。

- `draggable="true"`
- `data-tree-transfer-payload`
- `data-tree-transfer-node-key`
- `data-action="dragstart->tree-view-transfer#start dragover->tree-view-transfer#over drop->tree-view-transfer#drop"`

`data-tree-transfer-payload` には `row_event_payload_builder` の戻り値をJSON化した文字列が入ります。

## Events

`tree-view-transfer` controller は以下のStimulus eventをdispatchします。

| event | timing | detail |
|---|---|---|
| `tree-view-transfer:drag-start` | drag開始時 | `sourcePayload`, `sourceRow` |
| `tree-view-transfer:drag-over` | drop候補上をdrag中 | `targetPayload`, `targetRow`, `position` |
| `tree-view-transfer:drop` | drop時 | `sourcePayload`, `targetPayload`, `targetRow`, `position` |

`position` はdrop位置の目安です。

- `before`
- `inside`
- `after`

```js
document.addEventListener("tree-view-transfer:drop", (event) => {
  const { sourcePayload, targetPayload, position } = event.detail

  // host app側で親変更や並び順保存APIを呼ぶ
})
```

## Payload validation

`row_event_payload_builder` はHash相当の値を返してください。

```ruby
row_event_payload_builder: ->(item) { { id: item.id } }
```

Hash相当ではない値を返した場合は、誤実装に気づきやすいよう `ArgumentError` を発生させます。

## Out of scope

以下は `tree_view` では扱いません。

- DB更新
- 並び順保存
- drop可否判定
- drop後の画面更新API
- 複雑なdrag/drop UIライブラリへの依存

host app 側では、payload内の `id` / `type` / `key` などを使って保存処理を実装してください。
