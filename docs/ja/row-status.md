# Row status

このページでは、TreeView の行全体に disabled / readonly の状態と任意の disabled reason を付けるための hook を説明します。

## 概要

Row status は、node 単位で行全体の状態を表現するための表示 hook です。

TreeView gem が担当するのは以下です。

- 設定されている `row_disabled_builder`、`row_readonly_builder`、`row_disabled_reason_builder` を評価する
- status に応じた class や data 属性を行に追加する
- host app の row class/data builder と結合する

実際の業務ルール、操作制御、認可、保存処理は host app 側で実装します。

行全体の status cue、selection checkbox の disabled state、depth label を並べて確認したい場合は、[row status and depth label mockup](../mockups/row-status-depth-labels.html) を参照してください。mockup は static reference であり、API と責務境界の説明はこの guide を正とします。

## 基本例

行全体の状態ごとに専用 builder を使います。各 builder は行 item を受け取り、その状態を付ける場合だけ `true` を返します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_disabled_builder: ->(document) { document.archived? },
  row_readonly_builder: ->(document) { document.locked? },
  row_disabled_reason_builder: ->(document) {
    document.archived? ? "Archived documents cannot be changed" : nil
  }
)
```

disabled row には `tree-view-row--disabled` class と `data-tree-view-row-disabled="true"` が追加されます。

readonly row には `tree-view-row--readonly` class と `data-tree-view-row-readonly="true"` が追加されます。

`row_disabled_reason_builder` が present な値を返すと、TreeView は `data-tree-view-row-disabled-reason` にその値を追加します。reason をユーザーへどう見せるかは host app 側の責務です。

## row_class_builder / row_data_builderとの関係

TreeView は row status の出力を host app の `row_class_builder` / `row_data_builder` と結合します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_disabled_builder: ->(document) { document.archived? },
  row_readonly_builder: ->(document) { document.locked? },
  row_disabled_reason_builder: ->(document) { document.archived? ? "archived" : nil },
  row_class_builder: ->(document) { ["document-row", document.status] },
  row_data_builder: ->(document) { { document_id: document.id } }
)
```

TreeView は host app 側の class / data を残したうえで、`row_disabled_builder` または `row_readonly_builder` が `true` を返したときに documented な TreeView status class/data key を追加します。disabled reason は `row_disabled_reason_builder` が present な値を返したときに追加されます。

## selectionとの違い

selection の `disabled_builder` は checkbox を選択不可にします。

row status は行全体の見た目や状態を表すための hook です。

| 目的 | API |
|---|---|
| checkbox を選択不可にする | `selection[:disabled_builder]` |
| 行全体を disabled 風に見せる | `row_disabled_builder` |
| 行全体を readonly 風に見せる | `row_readonly_builder` |
| 行全体の disabled reason を付ける | `row_disabled_reason_builder` |

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| status builder invocation | yes | provides builders |
| row class/data merge | yes | provides additional attributes |
| business rule | no | yes |
| authorization | no | yes |
| action disabling | no | yes |
| disabled reason display | no | yes |
| CSS styling | no | yes |
