# FilteredTree

`TreeView::FilteredTree` は、検索・絞り込み結果を通常の `tree_view` partial で描画するための部分Treeです。

検索処理そのものは host app 側の責務です。`tree_view` は、検索にhitしたnode群をどの範囲でTree表示するかだけを扱います。

## 基本形

```ruby
filtered_tree = tree.filtered_tree_for(
  matched_documents,
  mode: :with_ancestors
)

render_state = TreeView::RenderState.new(
  tree: filtered_tree,
  root_items: filtered_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  highlighted_keys: matched_documents.map { |item| tree.node_key_for(item) }
)
```

`filtered_tree_for` は `TreeView::FilteredTree` を返します。返されたオブジェクトは `root_items`、`children_for`、`descendant_counts`、`node_key_for`、`sort_items` を持つため、通常の `RenderState` / `tree_view_rows` と組み合わせられます。

## modes

| mode | 表示対象 | 主な用途 |
|---|---|---|
| `:matched_only` | hit node のみ | フラットな検索結果一覧に近い表示 |
| `:with_ancestors` | hit node + ancestors | hit位置を通常階層内で見せる |
| `:with_descendants` | hit node + descendants | hitしたカテゴリ・親配下を展開して見せる |
| `:with_ancestors_and_descendants` | hit node + ancestors + descendants | hit位置と配下の両方を見せる |

## matched_only

`matched_only` は、hit nodeだけをrootとして扱います。

```ruby
filtered_tree = tree.filtered_tree_for(matches, mode: :matched_only)
```

hit node同士が元のTree上で親子関係を持っていても、`matched_only` では親子関係を復元しません。検索結果だけを一覧的に並べたい場合に使います。

## with_ancestors

`with_ancestors` は、hit nodeまでの親階層を補完します。

```ruby
filtered_tree = tree.filtered_tree_for(matches, mode: :with_ancestors)
```

これは `path_tree_for` に近い用途ですが、検索結果表示のmodeとして扱える入口です。

## with_descendants

`with_descendants` は、hit nodeとその配下を表示します。

```ruby
filtered_tree = tree.filtered_tree_for(matches, mode: :with_descendants)
```

hitしたカテゴリ、工程、フォルダなどの配下をまとめて確認したい場合に使います。

## with_ancestors_and_descendants

`with_ancestors_and_descendants` は、hit nodeまでの親階層と、hit node配下の両方を表示します。

```ruby
filtered_tree = tree.filtered_tree_for(matches, mode: :with_ancestors_and_descendants)
```

検索結果の位置も見せたいが、その配下も同時に確認したい場合に使います。

## 注意点

- 検索条件、DB query、highlight処理自体は host app 側の責務です。
- `highlighted_keys` を使う場合は、hit node の `node_key` を `RenderState` に渡してください。
- `with_ancestors` / `with_ancestors_and_descendants` は親方向helperを使うため、現時点では records mode 向けです。
- `with_descendants` は `children_for` を辿れるTreeであれば利用できます。
- node_key / DOM ID の重複がある場合は、通常のTree描画と同様にhost app側で一意性を保つ必要があります。
