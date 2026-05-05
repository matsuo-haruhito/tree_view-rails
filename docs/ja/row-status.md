# Row status

このページでは、TreeViewの行全体に disabled / readonly などの状態を付けるためのhookを説明します。

## 概要

Row status は、node単位で行全体の状態を表現するための表示hookです。

TreeView gem が担当するのは以下です。

- row status builderを評価する
- statusに応じたclassやdata属性を行に追加する
- host appのrow class/data builderと結合する

実際の業務ルール、操作制御、認可、保存処理はhost app側で実装します。

## 基本例

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_status_builder: ->(document) {
    if document.archived?
      :disabled
    elsif document.locked?
      :readonly
    end
  }
)
```

## hashで返す

複数の属性を制御したい場合はhash-like valueを返します。

```ruby
row_status_builder = ->(document) {
  next unless document.archived?

  {
    status: :disabled,
    class: "is-archived",
    data: {
      reason: "archived"
    }
  }
}
```

## row_class_builder / row_data_builderとの関係

`row_status_builder` が返すclassやdataは、host appの `row_class_builder` / `row_data_builder` と結合されます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_status_builder: ->(document) { document.archived? ? :disabled : nil },
  row_class_builder: ->(document) { ["document-row", document.status] },
  row_data_builder: ->(document) { { document_id: document.id } }
)
```

## selectionとの違い

selectionの `disabled_builder` はcheckboxを選択不可にします。

row status は行全体の見た目や状態を表すためのhookです。

| 目的 | API |
|---|---|
| checkboxを選択不可にする | `selection[:disabled_builder]` |
| 行全体をdisabled / readonly風に見せる | `row_status_builder` |

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| status builder invocation | yes | provides builder |
| row class/data merge | yes | provides additional attributes |
| business rule | no | yes |
| authorization | no | yes |
| action disabling | no | yes |
| CSS styling | no | yes |
