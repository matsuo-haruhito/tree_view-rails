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
- expanded keys for paths

開発中やrelease前の確認、host app側のデータ不整合調査に使います。

## node key uniqueness

node keyの重複を検出したい場合は、tree作成時にvalidationを有効にします。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  validate_node_keys: true
)
```

重複がある場合は `ArgumentError` になります。

## DOM ID collision

rendered DOM IDの衝突を確認したい場合は `RenderState#validate_unique_dom_ids!` を使います。

```ruby
render_state.validate_unique_dom_ids!
```

selection checkboxなど、設定に応じて生成されるDOM IDも検査対象になります。

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

## parent path helpers

対象itemの親階層を確認できます。

```ruby
tree.parent_for(document)
tree.ancestors_for(document)
tree.path_for(document)
tree.paths_for(documents)
```

検索結果を初期表示で開きたい場合は、pathからexpanded keysを作れます。

```ruby
expanded_keys = tree.expanded_keys_for_paths([document])
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
