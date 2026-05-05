# Filtered Trees

このページでは、検索結果や絞り込み結果をTreeViewとして表示するための filtered tree を説明します。

## 概要

filtered tree は、base treeから条件に合うnodeと、その表示に必要な周辺nodeを取り出して描画するための仕組みです。

主な用途:

- 検索にmatchしたnodeだけを表示する
- matchしたnodeと祖先を表示する
- matchしたnodeと子孫を表示する
- matchしたnode、祖先、子孫をまとめて表示する

## 基本例

```ruby
matched_documents = documents.select { |document| document.name.include?(params[:q].to_s) }
filtered_tree = tree.filtered_tree_for(matched_documents, mode: :with_ancestors)

render_state = TreeView::RenderState.new(
  tree: filtered_tree,
  root_items: filtered_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

## mode

| mode | 意味 |
|---|---|
| `:matched_only` | matchしたnodeだけを含めます。 |
| `:with_ancestors` | matchしたnodeと祖先を含めます。 |
| `:with_descendants` | matchしたnodeと子孫を含めます。 |
| `:with_ancestors_and_descendants` | matchしたnode、祖先、子孫を含めます。 |

## PathTreeとの違い

`path_tree_for` は、指定itemまでのpathを補完して表示します。

filtered tree は、filter modeに応じてmatch周辺のnode集合を作ります。

| 目的 | API |
|---|---|
| 検索結果までのpathを表示 | `path_tree_for(items)` |
| matchと祖先/子孫をmodeで切り替える | `filtered_tree_for(items, mode:)` |

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| filtered tree construction | yes | provides matched items |
| filter modes | yes | chooses mode |
| search query | no | yes |
| authorization | no | yes |
| result ranking | no | yes |
| highlighting text | no | yes |
