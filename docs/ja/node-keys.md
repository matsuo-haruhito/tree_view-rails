# Node keys

このページでは、TreeViewでnodeを識別する `node_key` の考え方を説明します。

## 概要

`node_key` は、TreeView内でnodeを一意に扱うためのkeyです。

主にtree側の状態やpayloadで使われます。

- `expanded_keys`
- `collapsed_keys`
- `selected_keys`
- persisted state
- row event payload
- diagnostics

TreeViewは、DOM IDなどブラウザ側の値を生成するときにnode keyを入力として使うこともあります。ただしUI層は `UiConfig` / `UiConfigBuilder` で別に設定されます。UI側のDOM ID builderを変更しても、tree本体が使うnode keyが変わるわけではありません。

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

## node keyとUI識別子

TreeViewには、関連しているが責務が異なる2種類の識別子があります。

| 層 | 設定する場所 | 使われる場所 |
|---|---|---|
| Tree node key | `id_method:` または `node_key_resolver:` | tree構造のlookup、開閉状態、selection状態、persisted state、row payload、diagnostics。 |
| UI識別子 / DOM ID | `UiConfig` と `UiConfigBuilder` のDOM ID builder | HTML ID、Turbo target、row属性、ブラウザ側hook。 |

`expanded_keys`、`collapsed_keys`、grouped `initial_expansion:` などの開閉関連optionは、tree node keyと一致している必要があります。host appが意図して同じ安定値を両方の層で使っていない限り、UIだけのDOM IDとは一致しません。

異種node treeでは、1つの安定したkey生成方針を定義し、tree stateとUI層で同じ値を使いたい場所に再利用すると安全です。

```ruby
node_key = ->(node) { TreeView.node_key(node.class.name, node.id) }

tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: node_key
)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  expanded_keys: [node_key.call(current_section)]
)
```

初期展開やpersisted stateが期待した行に効かない場合は、UIだけのDOM ID設定を変える前に `tree.node_key_for(item)` を確認してください。

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
