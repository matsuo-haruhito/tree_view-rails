# API仕様

このページでは、TreeViewの主要な公開APIを日本語で整理します。

詳細な使い方は [使い方](usage.md)、具体例は [Cookbook](cookbook.md)、概念は [用語集](glossary.md) も参照してください。

## TreeView::Tree

親子データをtreeとして扱う中心オブジェクトです。

### records mode

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  id_method: :id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) },
  orphan_strategy: :ignore
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `records:` | yes | tree化するrecords。 |
| `parent_id_method:` | yes | 親IDを返すmethod名。 |
| `id_method:` | no | 自身のIDを返すmethod名。既定値は `:id`。 |
| `sorter:` | no | root / children の並び順を決めるcallable。 |
| `orphan_strategy:` | no | 親recordがrecords内に存在しないnodeの扱い。 |
| `validate_node_keys:` | no | 初期化時にnode_key重複を検出するか。 |

### resolver mode

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
)
```

### adapter mode

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
)

tree = TreeView::Tree.new(adapter: adapter)
```

### 主なメソッド

| メソッド | 説明 |
|---|---|
| `root_items(root_parent_id = nil)` | root nodeを返す。 |
| `children_for(item)` | 指定nodeのchildrenを返す。 |
| `parent_for(item)` | 指定nodeの親を返す。records modeのみ。 |
| `ancestors_for(item)` | root側から親までの祖先配列を返す。records modeのみ。 |
| `path_for(item)` | root側から指定nodeまでのpath配列を返す。records modeのみ。 |
| `paths_for(items)` | 複数nodeのpath配列を返す。records modeのみ。 |
| `path_tree_for(items)` | 指定itemsまでの親階層を補完した `PathTree` を返す。 |
| `reverse_tree_for(items)` | 指定itemsから親方向へ辿る `ReverseTree` を返す。 |
| `filtered_tree_for(items, mode:)` | match周辺nodeを含むfiltered treeを返す。 |
| `descendant_counts` | node_keyごとの子孫数を返す。 |
| `node_key_for(item)` | nodeを識別するkeyを返す。 |
| `sort_items(items)` | sorterに従ってitemsを並べ替える。 |
| `orphan_items` | records内に親が存在しないnodeを返す。 |
| `validate_unique_node_keys!` | node_key重複を検出する。 |

## TreeView::PathTree / ReverseTree

`path_tree_for(items)` は root → parent → matched item の通常向きtreeを作ります。

`reverse_tree_for(items)` は matched item → parent → root の逆向きtreeを作ります。

| API | 表示方向 | 主な用途 |
|---|---|---|
| `path_tree_for(items)` | root → parent → matched item | 検索結果を通常階層の中で見せる。 |
| `reverse_tree_for(items)` | matched item → parent → root | 子node一覧から親方向へ辿る。 |

## TreeView::FilteredTree

検索や絞り込み結果をtreeとして表示するためのwrapperです。

```ruby
filtered_tree = tree.filtered_tree_for(matched_items, mode: :with_ancestors)
```

| mode | 説明 |
|---|---|
| `:matched_only` | matchしたnodeだけを含める。 |
| `:with_ancestors` | matchしたnodeと祖先を含める。 |
| `:with_descendants` | matchしたnodeと子孫を含める。 |
| `:with_ancestors_and_descendants` | match、祖先、子孫を含める。 |

## TreeView::VisibleRows

現在の `RenderState` に基づく表示対象行を一次元配列として取得します。

```ruby
visible_rows = TreeView::VisibleRows.new(
  tree: tree,
  root_items: tree.root_items,
  render_state: render_state
).to_a
```

各rowは概ね以下を持ちます。

| 属性 | 説明 |
|---|---|
| `item` | 元のnode。 |
| `depth` | root基準depth。 |
| `node_key` | `tree.node_key_for(item)` の値。 |
| `parent_key` | 親rowのnode_key。rootは `nil`。 |
| `has_children?` | childを持つか。 |
| `expanded?` | 現在の状態で展開扱いか。 |

## TreeView::RenderWindow

`VisibleRows` を `offset` / `limit` で切り出すwindowing helperです。

```ruby
window = TreeView::RenderWindow.new(
  rows: visible_rows,
  offset: 0,
  limit: 50
)
```

| API | 説明 |
|---|---|
| `rows` | window内のrows。 |
| `offset` | 開始位置。 |
| `limit` | 最大件数。 |
| `total_count` | window前の件数。 |
| `has_previous?` | 前windowがあるか。 |
| `has_next?` | 次windowがあるか。 |

## TreeView::RenderState

画面単位の描画状態をまとめるオブジェクトです。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    max_depth: 2,
    expanded_keys: expanded_keys
  },
  render_scope: {
    max_depth: 3,
    max_leaf_distance: 2
  },
  selection: {
    enabled: true,
    visibility: :leaves
  }
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `tree:` | yes | `TreeView::Tree` 相当のobject。 |
| `root_items:` | yes | 描画root node配列。 |
| `row_partial:` | yes | host app側の列描画partial。 |
| `ui_config:` | yes | `TreeView::UiConfig`。 |
| `initial_state:` | no | `:expanded` または `:collapsed`。 |
| `expanded_keys:` | no | 展開するtree側node key配列。`tree.node_key_for(item)` と一致する必要があり、UIだけのDOM IDではありません。 |
| `collapsed_keys:` | no | 折りたたむtree側node key配列。`tree.node_key_for(item)` と一致する必要があり、UIだけのDOM IDではありません。 |
| `initial_expansion:` | no | 初期展開設定group。このgroup内の展開keyにも同じtree側node keyの規則が適用されます。 |
| `render_scope:` | no | 描画範囲設定group。 |
| `toggle_scope:` | no | 開閉操作範囲設定group。 |
| `selection:` | no | checkbox selection設定group。 |
| `lazy_loading:` | no | lazy loading設定group。 |
| `row_class_builder:` | no | `tr` classを返すcallable。 |
| `row_data_builder:` | no | `tr` data属性を返すcallable。 |
| `badge_builder:` | no | row badge / marker 表示値を返すcallable。 |
| `icon_builder:` | no | row badge / marker 表示のcompatibility alias。新しいcodeでは `badge_builder` を推奨。 |
| `depth_label_builder:` | no | depth labelを返すcallable。 |
| `row_status_builder:` | no | row状態を返すcallable。 |
| `row_event_payload_builder:` | no | drag/drop transfer payloadを返すcallable。transfer専用であり、汎用row event hookではない。 |
| `persisted_state:` | no | 保存済み展開状態。 |

公開名の判断は [Public Name Decisions](public-name-decisions.md)、ARIA配置は [Accessibility Semantics](accessibility-semantics.md) を参照してください。識別子設計は [Node keys](node-keys.md) を参照してください。

## TreeView::UiConfig / UiConfigBuilder

DOM IDやpath builderをまとめる設定objectです。

### static

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_static
```

### turbo

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth: depth, scope: scope) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth: depth, scope: scope) },
  load_children_path_builder: ->(item, depth, scope) { children_document_path(item, depth: depth, scope: scope) },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)
```

## TreeView::PersistedState / StateStore

開閉状態をhost app側に保存・復元するためのAPIです。

```ruby
store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "documents:index"
)

persisted_state = store.load
store.save(expanded_keys: expanded_keys)
```

## Helpers

| Helper | 説明 |
|---|---|
| `tree_view_rows(render_state, window: nil)` | TreeView rowsを描画する。 |
| `tree_view_window(render_state, offset:, limit:)` | windowing metadataを返す。 |
| `tree_view_state_data(render_state)` | root要素用data属性を作る。 |
| `tree_node_dom_id(item, tree:, ui_config:)` | node DOM IDを作る。 |
| `tree_selection_value(item, tree:, render_state:)` | checkbox value用JSONを作る。 |
| `tree_view_breadcrumb(tree, item, ...)` | breadcrumbを描画する。 |

## JavaScript entrypoint

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

主なcontroller:

- `tree-view-selection`
- `tree-view-transfer`
- `tree-view-remote-state`

## 関連docs

- [API概要](api-overview.md)
- [使い方](usage.md)
- [Cookbook](cookbook.md)
- [Node keys](node-keys.md)
- [Tree diagnostics](tree-diagnostics.md)
- [Public API policy](../public-api.md)
