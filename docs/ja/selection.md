# Selection / 選択

TreeView は、nodeを選択するためのcheckbox cellを描画できます。

## 概要

selection は、TreeView上のnodeをcheckboxで選択し、host app側のformやJavaScript処理に渡すための機能です。

TreeView gem が担当するのは以下です。

- checkbox cell の描画
- checkbox value 用 JSON payload の生成
- 表示対象行に対する visibility 制御
- disabled checkbox と disabled reason の出力
- JavaScript controller による checked payload の収集
- rendered rows に限定した cascade / indeterminate 更新
- max count 超過時のイベント通知

削除、移動、関連付け、API送信、権限チェック、業務固有メッセージは host app 側で実装します。

## 最小設定

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    visibility: :leaves
  }
)
```

## 表示対象

`selection[:visibility]` で、どの行にcheckboxを描画するかを制御します。

| value | 意味 |
|---|---|
| `:all` | 描画されたすべてのnodeにcheckboxを表示します。 |
| `:roots` | 現在の描画treeのroot行だけにcheckboxを表示します。 |
| `:leaves` | 現在の描画treeでchildrenが空の行だけにcheckboxを表示します。 |
| `:none` | checkboxは表示せず、列揃え用の空cellだけを維持します。 |

既定値は `:all` です。

`selection[:enabled]` が `false` の場合、TreeViewはselection cell自体を描画しません。selectionが有効で、行がvisibility対象外の場合は、table columnを揃えるために空のselection cellを描画します。

## 送信値のparse

checkboxのvalueはJSON文字列です。host app側では以下でparseできます。

```ruby
selected_nodes = TreeView.parse_selection_params(params[:selected_nodes])
```

`TreeView.parse_selection_params` はJSON文字列配列を受け取り、parse済みのhash-like valuesを返します。不正なJSONは明確なerrorになります。

## disabled checkbox

選択できないnodeがある場合は `disabled_builder` を使います。

```ruby
selection: {
  enabled: true,
  disabled_builder: ->(document) { document.archived? },
  disabled_reason_builder: ->(document) {
    document.archived? ? "アーカイブ済みのため選択できません" : nil
  }
}
```

`disabled_reason_builder` の戻り値は、checkboxの `title` と `data-tree-selection-disabled-reason` に出力されます。

## JavaScript selection API

`tree-view-selection` は、描画済みselection checkboxからchecked node payloadを収集できます。

```erb
<tbody data-controller="tree-view-selection">
  <%= tree_view_rows(@render_state) %>
</tbody>

<button data-action="tree-view-selection#submit">
  Process selected nodes
</button>
```

`submit` 実行時、controllerは `tree-view-selection:selected` eventをdispatchします。

```js
document.addEventListener("tree-view-selection:selected", (event) => {
  console.log(event.detail.payloads)
})
```

controller接続時またはselection変更時には `tree-view-selection:change` をdispatchします。

```js
document.addEventListener("tree-view-selection:change", (event) => {
  const { selectedCount, selectedValues, selectedPayloads } = event.detail
})
```

対象になるのは、checked かつ enabled な `.tree-selection-checkbox` だけです。不正なJSON値はskipされ、`tree-view-selection:invalid-payload` で通知されます。

## 最大選択数

JavaScript controller側で、checked checkboxの最大数を制限できます。

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-max-count-value="10">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

上限を超えた場合、TreeViewは操作されたcheckboxをuncheckし、`tree-view-selection:limit-exceeded` をdispatchします。

```js
document.addEventListener("tree-view-selection:limit-exceeded", (event) => {
  const { maxCount, attemptedCount } = event.detail
})
```

controllerは上限超過eventを通知するだけです。業務固有の文言やAPI挙動はhost app側で実装します。

## 連動checkbox挙動

Stimulus controllerは、描画済みchild rowsとparent mixed stateも更新できます。

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-cascade-value="true"
  data-tree-view-selection-indeterminate-value="true">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

この挙動はDOMベースです。影響するのは描画済み行だけで、disabled checkboxはskipします。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| Rendering checkboxes | yes | no |
| JSON payload generation | yes | optional customization |
| Submitted value parsing | helper provided | owns controller behavior |
| Cascade / indeterminate | rendered DOM only | decides unloaded/server-side semantics |
| Max count event | dispatches event | shows message or blocks business action |
| Delete / move / relate / API calls | no | yes |
| Authorization | no | yes |
