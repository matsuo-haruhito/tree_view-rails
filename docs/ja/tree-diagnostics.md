# Tree diagnostics

このページでは、TreeViewの構造確認や問題調査に使うdiagnostics helperを説明します。

## 概要

Tree diagnostics は、tree構造の不整合や規模を確認するための補助APIです。

主に以下を確認できます。

- node key uniqueness
- DOM ID collision
- orphan records
- parent path
- tree stats
- cycle diagnostics
- expanded keys for items

開発中やrelease前の確認、host app側のデータ不整合調査に使います。

## 推奨validation入口

TreeViewをhost appに組み込むときは、描画前に次の流れで確認すると安全です。

1. `validate_node_keys: true` を付けてtreeを作り、node key重複を早期に検出する。
2. host appのdata policyに合う `orphan_strategy:` を決める。
3. recordsがfilter、import、permission scopeの影響を受ける場合は `tree.orphan_items` を確認する。
4. 実際に画面で使う `tree`、`root_items`、`row_partial`、`ui_config` で `RenderState` を作る。
5. 開発中、test、release前確認で `render_state.validate_unique_dom_ids!` を呼ぶ。
6. user編集可能な親子関係やimport dataを扱う場合は `TreeView::CycleDiagnostics.new(tree).report` を確認する。

最小の描画前チェックは次のように書けます。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  validate_node_keys: true,
  orphan_strategy: :raise
)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)

render_state.validate_unique_dom_ids!
```

これにより、host appは不正または意図しないtree dataを描画する前に、具体的なvalidation pointを持てます。

## node key uniqueness

node keyの重複を検出したい場合は、tree作成時にvalidationを有効にします。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  validate_node_keys: true
)
```

重複がある場合は `ArgumentError` になります。通常は、records modeの `id_method:`、または resolver / adapter mode の `node_key_resolver:` で安定して衝突しにくいkeyを返すように修正します。

## DOM ID collision

rendered DOM IDの衝突を確認したい場合は `RenderState#validate_unique_dom_ids!` を使います。

```ruby
render_state.validate_unique_dom_ids!
```

selection checkboxなど、設定に応じて生成されるDOM IDも検査対象になります。失敗した場合は、`node_prefix`、custom DOM ID builder、ブラウザ向けIDへ正規化したときに衝突するnode keyを確認してください。

## orphan diagnostics

records modeで親がrecords内に存在しないnodeを調べる場合は、orphan関連APIを使います。

```ruby
tree.orphan_items
```

`orphan_strategy` によって、orphanを無視する、root扱いにする、orphanだけ表示する、errorにする、などの挙動を選べます。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  orphan_strategy: :as_root
)
```

testやimport validationでは、orphanを不正dataとして扱いたい場合に `:raise` を選びます。permission scopeやfiltered subsetを独立rootとして見せることが意図した挙動の場合だけ `:as_root` を選んでください。

## parent path helpers

対象itemの親階層を確認できます。

```ruby
tree.parent_for(document)
tree.ancestors_for(document)
tree.path_for(document)
tree.paths_for(documents)
```

検索結果を初期表示で開きたい場合は、itemからexpanded keysを作れます。

```ruby
expanded_keys = tree.expanded_keys_for([document])
```

## tree stats

tree全体の規模やreachable nodesを確認したい場合はstats helperを使います。

```ruby
tree.stats
```

host app側で大きなtreeを扱う場合、render scope、windowed rendering、lazy loadingを検討する判断材料になります。

## cycle diagnostics

parent relationshipにcycleがある場合、descendant countやpath traversalで問題になります。

cycle diagnosticsは、開発時に不正な親子関係を調査するために使います。

```ruby
TreeView::CycleDiagnostics.new(tree).report
```

cycleが見つかった場合は、描画前にhost app側のdataやresolver logicを修正してください。TreeViewはriskを報告できますが、data correction policyはhost appの責務です。

## production前チェックリスト

新しいtreeをproductionで有効化する前に、以下を確認してください。

- node keyがrequestをまたいで安定し、描画対象node間で一意である。
- 異種nodeでは、class名、namespace、または同等の識別子をkeyに含めている。
- orphanは期待された挙動として文書化されているか、`orphan_strategy: :raise` で拒否している。
- DOM IDは、その画面で使うものと同じ `UiConfig` で検証済みである。
- initial expansionやpersisted stateには、UIだけのDOM IDではなくtree node keyを使っている。
- 大きなtreeでは、statsを見て選択したrender strategyと合っていることを確認している。
- import dataやuser編集可能なparent relationshipではcycleを確認している。

## 使いどころ

- release前にDOM IDやnode_keyの衝突を確認する
- import dataやmigration後にorphanを調べる
- 検索結果まで初期展開したいときにexpanded keysを作る
- 大きなtreeでrendering strategyを検討する
- host app側の不正なparent relationshipを調査する

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| diagnostics helper | yes | calls helper |
| duplicate key detection | yes | chooses stable keys |
| DOM ID collision detection | yes | fixes config/prefixes |
| orphan detection | yes | decides data policy |
| cycle report | yes | fixes data |
| rendering strategy decision | provides signals | chooses behavior |
