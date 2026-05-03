# API仕様

このドキュメントでは、`tree_view` の主要な公開APIと役割を整理します。

## TreeView::Tree

親子データをツリーとして扱うための中心オブジェクトです。

### records mode

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  id_method: :id
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `records:` | yes | ツリー化するレコード配列 |
| `parent_id_method:` | yes | 親IDを返すメソッド名 |
| `id_method:` | no | 自身のIDを返すメソッド名。既定値は `:id` |
| `sorter:` | no | root / children の並び順を決めるcallable |

### resolver mode

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `roots:` | yes | root node 配列 |
| `children_resolver:` | yes | nodeからchildrenを返すcallable |
| `node_key_resolver:` | no | node_keyを返すcallable |
| `id_method:` | no | node_key_resolver未指定時に使うIDメソッド |
| `sorter:` | no | root / children の並び順を決めるcallable |

### adapter mode

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)

tree = TreeView::Tree.new(adapter: adapter)
```

`GraphAdapter` を使うことで、異種ノード混在ツリーを扱いやすくします。

### 主なメソッド

| メソッド | 説明 |
|---|---|
| `root_items(root_parent_id = nil)` | root node を返す |
| `children_for(record)` | 指定nodeのchildrenを返す |
| `descendant_counts` | node_keyごとの子孫数を返す |
| `node_key_for(record)` | nodeを識別するkeyを返す |
| `sort_items(items)` | sorterに従ってitemsを並び替える |

### 並び順

既定では、子孫数の昇順で並びます。

```ruby
TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)
```

`sorter` は `call(items, tree)` できるオブジェクトを指定します。

## TreeView::GraphAdapter

異種ノード混在ツリーの接続を表現するためのadapterです。

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: [country],
  children_resolver: ->(node) { ... },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `roots:` | yes | root node 配列 |
| `children_resolver:` | yes | nodeからchildrenを返すcallable |
| `node_key_resolver:` | no | node_keyを返すcallable |

## TreeView::RenderState

画面単位の描画状態をまとめるオブジェクトです。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `tree:` | yes | `TreeView::Tree` 相当のオブジェクト |
| `root_items:` | yes | 描画するroot node配列 |
| `row_partial:` | yes | host app側の列描画partial |
| `ui_config:` | yes | `TreeView::UiConfig` |
| `initial_state:` | no | `:expanded` または `:collapsed` |

`effective_initial_state` は、画面固有指定、global config、既定値の順で解決します。

## TreeView::UiConfig

DOM IDや開閉pathの作り方をまとめるオブジェクトです。

主に `TreeView::UiConfigBuilder` から生成します。

### static

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static
```

staticでは開閉path builderを持ちません。

### turbo

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "item").build(
  hide_descendants_path_builder: ->(item, depth, scope) { ... },
  show_descendants_path_builder: ->(item, depth, scope) { ... },
  toggle_all_path_builder: ->(state) { ... }
)
```

| builder | 説明 |
|---|---|
| `hide_descendants_path_builder` | 子孫を閉じるpathを返す |
| `show_descendants_path_builder` | 子孫を開くpathを返す |
| `toggle_all_path_builder` | 全体開閉pathを返す |

## TreeViewHelper

viewから使う補助helperです。

| メソッド | 説明 |
|---|---|
| `tree_node_dom_id(item_or_id)` | nodeのDOM IDを返す |
| `tree_button_dom_id(item)` | toggle cell用DOM IDを返す |
| `tree_show_button_dom_id(item)` | show button用DOM IDを返す |
| `tree_hide_descendants_path(item, display_depth, scope: 'all')` | 閉じるpathを返す |
| `tree_show_descendants_path(item, toggle_depth, scope: 'all')` | 開くpathを返す |
| `tree_toggle_all_path(state:)` | 全体開閉pathを返す |
| `tree_expand_all_path` | 全体展開pathを返す |
| `tree_collapse_all_path` | 全体折りたたみpathを返す |
| `tree_branch_info(item, tree)` | 枝描画用情報を返す |
| `tree_toggle_mode(mode = nil)` | `:static` / `:turbo` を検証して返す |

`ui:` または `@tree_ui` が未設定のままDOM IDやpath系helperを呼ぶと、設定漏れが分かる `ArgumentError` を返します。

## TreeView::Traversal

子孫ID収集の補助モジュールです。

```ruby
map = TreeView::Traversal.child_ids_by_parent_id(pairs)
ids = TreeView::Traversal.descendant_ids(node_id, map, min_depth: 1, max_depth: 3)
```

| メソッド | 説明 |
|---|---|
| `child_ids_by_parent_id(pairs)` | `[id, parent_id]` の配列から親子mapを作る |
| `descendant_ids(node_id, child_ids_by_parent_id, min_depth:, max_depth:)` | 指定nodeの子孫IDを返す |

## Partial

TreeView本体は以下のpartialを提供します。

- `tree_view/tree_row`
- `tree_view/tree_children`
- `tree_view/tree_toggle_cell`
- `tree_view/tree_toggle_content`
- `tree_view/tree_toggle_content_static`
- `tree_view/tree_toggle_content_turbo`

host app は `row_partial` を指定して、業務固有の列部分を描画します。
