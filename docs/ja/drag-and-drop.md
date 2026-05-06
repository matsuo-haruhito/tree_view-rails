# Drag and Drop

このページでは、TreeViewのtransfer payloadを使ってdrag-and-drop UIをhost app側に実装するための境界を説明します。

## 概要

TreeView gem は、drag-and-dropの業務処理そのものは実装しません。

TreeView が提供するのは以下です。

- rowごとのtransfer payloadをdata属性として出力するhook
- `tree-view-transfer` controller
- drag start時にpayloadを `DataTransfer` へ入れる補助
- host appがdrop先でpayloadを読むための最低限のtransfer境界

実際のdrop target、並び替え保存、親変更、認可、validation、Turbo Stream更新、エラー表示はhost app側で実装します。

## row transfer payload

`row_event_payload_builder` に、drag/dropで渡したいpayloadを返すcallableを指定します。

歴史的な名前に反して、`row_event_payload_builder` はtransfer専用です。すべてのrow event向けの汎用payload hookではありません。詳細は [Public Name Decisions](public-name-decisions.md) を参照してください。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_event_payload_builder: ->(document) {
    {
      key: tree.node_key_for(document),
      id: document.id,
      type: document.class.name
    }
  }
)
```

戻り値はhash-like objectである必要があります。

## viewでの利用例

```erb
<tbody data-controller="tree-view-transfer">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

行側に `draggable` や `dragstart` actionを付けたい場合は、host appのrow partialやrow data builderで必要な属性を追加します。

```ruby
row_data_builder: ->(document) {
  {
    action: "dragstart->tree-view-transfer#start",
    draggable: "true"
  }
}
```

## draggable row内のinteractive control

`draggable` なrowにも、link、button、input、select、textarea、`contenteditable` label などのhost app controlを配置できます。TreeViewはこれらのnative interactive controlから発生したdrag start eventを無視するため、control操作が誤ってrow transferを開始することはありません。

native controlではないcustom widgetでは、row内のwidgetまたはその祖先にTreeView markerを付けます。

```erb
<td>
  <span data-tree-view-interactive="true">Custom picker</span>
</td>
```

Drag startだけを無視し、他のTreeView動作は残したい場合は `data-tree-view-ignore-drag="true"` を使います。

```erb
<td>
  <span data-tree-view-ignore-drag="true">Drag-safe widget</span>
</td>
```

keyboardやrow interaction向けのmarkerは [使い方](usage.md#行内のinteractive-control) を参照してください。

## drop処理

drop先はhost app側で実装します。

```js
function onDrop(event) {
  const payload = JSON.parse(event.dataTransfer.getData("application/json"))
  // payload.id, payload.key, payload.type を使ってhost app側の処理を行う
}
```

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| row transfer payload builder validation | yes | provides builder |
| transfer data attributes | yes | consumes them |
| dragstart helper | yes | wires action |
| interactive-control drag-start guard | yes | marks custom widgets when needed |
| drop target | no | yes |
| reorder / move persistence | no | yes |
| authorization | no | yes |
| validation | no | yes |
| Turbo Stream update | no | yes |
| error handling | no | yes |

## 設計方針

TreeViewは「どのnodeがdragされたか」を安全に渡すところまでを担当します。

「どこにdropできるか」「drop後にどのような親子関係・並び順にするか」は、業務仕様ごとに異なるためhost app側の責務です。
