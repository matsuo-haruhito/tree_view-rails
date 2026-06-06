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

host app がすでに `tree_view/index.js` を import しているなら、listener 配線では `TreeViewEventNames` を使うと raw event name string を写経せずに済みます。raw string 自体も引き続き documented event contract の一部です。詳細は [JavaScript event contract](js-events.md) と [Public API](public-api.md) を参照してください。

`submit` 実行時、controllerは `tree-view-selection:selected` eventをdispatchします。

```js
import { TreeViewEventNames } from "tree_view"

document.addEventListener(TreeViewEventNames.selection.selected, (event) => {
  console.log(event.detail.payloads)
})
```

controller接続時またはselection変更時には `tree-view-selection:change` をdispatchします。

```js
import { TreeViewEventNames } from "tree_view"

document.addEventListener(TreeViewEventNames.selection.change, (event) => {
  const { selectedCount, selectedValues, selectedPayloads } = event.detail
})
```

対象になるのは、checked かつ enabled な `.tree-selection-checkbox` だけです。不正なJSON値はskipされ、同じ documented invalid-payload event (`TreeViewEventNames.selection.invalidPayload` または raw `tree-view-selection:invalid-payload`) で通知されます。

## 通常form送信用の hidden input 同期

tree が通常の HTML form の中にある場合、同じ controller で checked payload を最寄りの form に hidden input としてミラーできます。

```erb
<form action="/documents/bulk_update" method="post">
  <table>
    <tbody
      data-controller="tree-view-selection"
      data-action="change->tree-view-selection#toggle"
      data-tree-view-selection-hidden-input-name-value="selected_nodes[]">
      <%= tree_view_rows(@render_state) %>
    </tbody>
  </table>
</form>
```

`data-tree-view-selection-hidden-input-name-value` を指定すると、TreeView は valid な checked payload ごとに hidden input を 1 つずつ生成し、connect / change / submit / manual refresh に追従して同期します。

host app が package root をすでに import している場合、JavaScript から host-authored attribute name を参照するときは `TreeViewSelectionDataHooks.hiddenInputNameValue` を使うと raw string の写経を避けられます。

```js
import { TreeViewSelectionDataHooks } from "tree_view"

const hiddenInputNameAttribute = TreeViewSelectionDataHooks.hiddenInputNameValue
```

- hidden input の `name` は host app 側で決められます。
- value は JSON 文字列で書き込まれるため、`TreeView.parse_selection_params(params[:selected_nodes])` をそのまま使えます。
- disabled checkbox と不正な JSON payload は既存 event と同じく skip されます。
- tree が form の外にある場合は、selection event だけを dispatch し、hidden input は生成しません。
- generated hidden input marker attribute と source-id attribute は TreeView が生成・管理する内部寄りの属性であり、host app が authoring する public hook ではありません。

1つの form に複数の `tree-view-selection` controller がある場合、TreeView は生成した hidden input に `data-tree-view-selection-source-id` を付けます。これにより、各 controller は自分が生成した hidden input だけを削除・再生成します。controller element に `data-tree-view-selection-source-id` がすでにある場合はその値を使い、なければ connect 時に自動生成します。tree ごとに別々の params として受け取りたい場合は、`data-tree-view-selection-hidden-input-name-value` に別々の名前を指定してください。同じ名前を使うのは、server-side action が1つの配列としてまとめて受け取る設計のときに限ります。

[selection-multi-tree-form.html](../mockups/selection-multi-tree-form.html) などの static mockup は generated hidden input を review aid として見せることがありますが、送信 contract の正本はこの節です。TreeView は 1 hidden input に 1 JSON payload をミラーし、最終的な params grouping と summary copy は host app 側で決めます。

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
import { TreeViewEventNames } from "tree_view"

document.addEventListener(TreeViewEventNames.selection.limitExceeded, (event) => {
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
| Submitted value parsing と hidden input sync | helper 提供、form bridge は optional | controller の配置と業務 action を決める |
| Cascade / indeterminate | rendered DOM only | decides unloaded/server-side semantics |
| Max count event | dispatches event | shows message or blocks business action |
| Delete / move / relate / API calls | no | yes |
| Authorization | no | yes |
