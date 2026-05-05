# Node keys

このページでは、TreeViewでnodeを識別する `node_key` の考え方を説明します。

## 概要

`node_key` は、TreeView内でnodeを一意に扱うためのkeyです。

主に以下で使われます。

- `expanded_keys`
- `collapsed_keys`
- `selected_keys`
- DOM ID生成
- persisted state
- row event payload
- diagnostics

通常のrecords modeではrecord idをそのまま使えますが、同じ画面に複数treeがある場合や、異種nodeを同じtreeで扱う場合は衝突に注意してください。

## records mode

records modeでは、既定で `id_method` の値を使います。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)

tree.node_key_for(document)
```

`id_method:` を変更することもできます。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  id_method: :uuid
)
```

## resolver / adapter mode

resolver modeやadapter modeでは、`node_key_resolver` を使って明示的にkeyを作ることを推奨します。

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)
```

異種nodeを扱う場合は、class名やnamespaceを含めると衝突を避けやすくなります。

## TreeView.node_key helper

複数の値から安定したkeyを作る場合は `TreeView.node_key` を使えます。

```ruby
TreeView.node_key("document", document.id)
TreeView.node_key(document.class.name, document.id)
```

空白は正規化され、DOM IDなどで使いやすい形になります。

## 衝突を避ける例

悪い例:

```ruby
node_key_resolver: ->(node) { node.id }
```

`Document#id == 1` と `Folder#id == 1` が同じtreeにある場合に衝突します。

良い例:

```ruby
node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
```

## uniqueness validation

node keyの重複を早期に検出したい場合は、uniqueness validationを有効にします。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  validate_node_keys: true
)
```

重複がある場合は明確なerrorになります。

## 設計方針

`node_key` はhost appのdomain idそのものとは限りません。

TreeView上で「同じnodeとして扱いたい単位」を表すkeyとして設計してください。

| 状況 | 推奨 |
|---|---|
| 単一modelのrecords mode | record idで十分なことが多い |
| 複数model混在 | class名 + id |
| 同じrecordを複数treeで表示 | tree prefix + class名 + id |
| persisted stateを使う | 長期的に安定するkey |
| DOM ID collisionを避けたい | namespaceを含める |
