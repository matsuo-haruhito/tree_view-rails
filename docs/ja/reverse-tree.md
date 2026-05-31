# ReverseTree

`TreeView::ReverseTree` は、matched item から親方向へ向かう path を tree として描画するための wrapper です。起点にしたい record が子側にあり、その親階層を下方向に見せたい場合に使います。

このガイドは public helper である `Tree#reverse_tree_for(items)` を説明します。resolver mode support、GraphAdapter support、breadcrumb の挙動、host app の navigation policy は追加しません。

## 使う場面

`reverse_tree_for` は、match した record や選択した record を描画上の root として見せたい場合に使います。

代表例:

- 検索結果で、match した leaf record を最初に見せたい場合
- audit / dependency view で、子 record から親 chain を説明したい場合
- full hierarchy を root から表示すると重要な match が埋もれる compact context panel

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)

reverse_tree = tree.reverse_tree_for(@matched_documents)

render_state = TreeView::RenderState.new(
  tree: reverse_tree,
  root_items: reverse_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

描画方向は matched item -> parent -> root になります。元 record、node key、sorter、row partial、UI config は、通常の TreeView rendering pipeline と同じものを使います。

## 関連APIとの違い

| API | 方向 | 使う場面 |
|---|---|---|
| `path_tree_for(items)` | root -> parent -> matched item | 検索・絞り込み結果を通常の階層内に表示したい場合。 |
| `reverse_tree_for(items)` | matched item -> parent -> root | match した item を起点にして、祖先をその下に見せたい場合。 |
| `PathTreeBuilder` | generated folder nodes -> record nodes | record が path 文字列や path segment を持つが、DB に folder record がない場合。 |
| `tree_view_breadcrumb(tree, item, ...)` | inline ancestor label trail | row tree ではなく、短い path label を表示したい場合。 |

`ReverseTree` は row を描画するための tree wrapper です。Breadcrumb は 1 つの path を短い表示にする helper です。`PathTreeBuilder` は generated folder structure 用で、`ReverseTree` は records-mode tree に既に含まれる実 record から parent path を作ります。

## records mode 前提

`Tree#reverse_tree_for(items)` は `paths_for(items)` に依存します。`paths_for` は `parent_for`、`ancestors_for`、`path_for` などの親方向 path helper を使います。

これらは records mode の helper です。base tree は `records:` と `parent_id_method:` で作ってください。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  id_method: :id
)
```

resolver mode や adapter mode では `reverse_tree_for` を使わないでください。これらの mode には parent ID lookup table がないため、TreeView は matched item から root までの path を導出できません。

graph-like または異種 node の data を扱う場合は、通常の tree には adapter mode を使い、逆方向 path 表示はその mode 向けの明示的 API が追加されるまでは host app 側の表現として扱ってください。

## shared ancestor の扱い

複数の matched record が同じ ancestor を共有する場合、`ReverseTree` はその ancestor を最初に出会った reverse path にだけ attach します。

例:

```text
child A -> parent -> root
child B -> parent -> root
```

この場合、reverse tree は `child A` の下に `parent -> root` を描画し、`child B` は同じ parent row を繰り返さない独立 root として残します。

これは意図した挙動です。TreeView の row partial と helper が生成する DOM ID は元 record に基づきます。同じ ancestor record を複数の matched leaf の下に描画すると、ページ内で DOM ID が重複します。first-path attachment にすることで、出力の DOM を有効に保ちながら、1 本の ancestor chain を見せます。

host app が各 match の下に同じ ancestor を繰り返して見せたい場合、それは別の presentation decision です。DOM ID が重複しないように、distinct wrapper record や host-app-owned markup を使ってください。

## reversed tree 内の descendant counts

`ReverseTree#descendant_counts` は、元の root-first tree ではなく、reversed view の内部で descendant を数えます。

`child -> parent -> root` という reverse path では次のようになります。

- `child` の reverse tree 内 descendant は 2 件
- `parent` の reverse tree 内 descendant は 1 件
- `root` の reverse tree 内 descendant は 0 件

これは TreeView render state や sorter が、渡された tree object を基準に構造を確認するためです。screen が `reverse_tree` を `tree` として使う場合、descendant counts はその reversed presentation の count として扱ってください。

## 責務境界

TreeView が担うこと:

- records-mode parent relationship から reverse path を作る
- node key と sorting を base tree に委譲する
- shared ancestor を一度だけ attach して、ancestor DOM ID の重複を避ける
- reversed tree の root items、children、descendant counts を提供する

host app が担うこと:

- `reverse_tree_for` に渡す matched records を選ぶ
- それらの records を load / authorize する
- screen に reversed view が適しているか判断する
- tree 周辺の route、breadcrumb、action、business wording を決める

## 関連ドキュメント

- [API概要](api-overview.md#親方向path-helper)
- [API仕様: TreeView::PathTree / ReverseTree](api.md#treeviewpathtree--reversetree)
- [Breadcrumb](breadcrumb.md)
- [PathTreeBuilder](path-tree-builder.md)
- [Node key 設計](node-keys.md)
