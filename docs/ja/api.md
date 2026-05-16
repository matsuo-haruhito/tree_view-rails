# API仕様

このページでは、TreeViewの主要な公開APIを日本語で整理します。

詳細な使い方は [使い方](usage.md)、具体例は [Cookbook](cookbook.md)、概念は [用語集](glossary.md) も参照してください。

## TreeView configuration

host app は `TreeView.configure` で TreeView 全体の既定値を設定できます。

```ruby
TreeView.configure do |config|
  config.initial_state = :collapsed
  config.render_log_level = :warn
end
```

| option | 既定値 | 説明 |
|---|---|---|
| `initial_state` | `:expanded` | 画面単位の `RenderState` が上書きしない場合のグローバルな初期展開状態。 |
| `render_log_level` | `:warn` | TreeView helper 経由の partial render 中に使う logger silence 閾値。`nil` にすると Rails 標準の partial render log をそのまま出します。 |

`render_log_level` は `:debug`, `:info`, `:warn`, `:error`, `:fatal`, `:unknown`, `nil`、または対応する Ruby `Logger` level constant を受け付けます。詳細は [render log level](render-log-level.md) を参照してください。

## TreeView errors

TreeView の validation / configuration failure は、`TreeView::Error` を基底とする公開 error hierarchy を使います。

`TreeView::Error` は、既存 host app が TreeView の validation failure を `ArgumentError` として rescue している場合の互換性を保つため、`ArgumentError` を継承します。

| Error class | 説明 |
|---|---|
| `TreeView::Error` | documented された TreeView validation / configuration failure の基底 class。 |
| `TreeView::ConfigurationError` | 不正な option、不正な mode 組み合わせ、不正な builder、未対応の configuration value。 |
| `TreeView::InvalidTreeError` | tree data を有効な tree として扱えない場合。 |
| `TreeView::DuplicateNodeKeyError` | node key の重複が検出された場合。 |
| `TreeView::CycleDetectedError` | parent / child cycle が検出された場合。 |
| `TreeView::InvalidRenderWindowError` | render window に不正な `offset` または `limit` が渡された場合。 |

rescue 例と互換性方針は [Error hierarchy](errors.md) を参照してください。

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

## TreeView::PathTreeBuilder

`PathTreeBuilder` は、path らしい値を持つ records から生成folder nodeとrecord nodeで構成されたtreeを作ります。database上にfolder recordを持たず、record側にpathだけがある場合に使います。

```ruby
builder = TreeView::PathTreeBuilder.new(
  records: documents,
  path_resolver: ->(document) { document.source_relative_path },
  label_resolver: ->(document) { document.title },
  id_resolver: ->(document) { TreeView.node_key(:document, document.id) },
  sort: { folders_first: true }
)

render_state = TreeView::RenderState.new(
  tree: builder.tree,
  root_items: builder.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `records:` | yes | path らしい値を持つsource records。 |
| `path_resolver:` | yes | 文字列pathまたはpath segment配列を返すcallable。 |
| `label_resolver:` | no | record node labelを返すcallable。 |
| `id_resolver:` | no | record node keyを返すcallable。安定したtyped keyを使う場合に指定します。 |
| `sorter:` | no | 独自の `TreeView::Tree` 形式sorter。 |
| `sort:` | no | default sort用option。`folders_first:` をサポートします。 |
| `separator:` | no | 文字列path用separator。既定値は `/`。 |
| `folder_key_prefix:` | no | 生成folder keyのprefix。既定値は `folder`。 |
| `record_key_prefix:` | no | 既定record keyのprefix。既定値は `record`。 |

builder は `nodes`, `paths`, `tree`, `root_items`, `children_for(node)`, `node_key_for(node)` を公開します。folder node は `TreeView::PathTreeBuilder::FolderNode`、record node は `TreeView::PathTreeBuilder::RecordNode` で、元recordを `record` に保持します。

具体例と責務境界は [PathTreeBuilder](path-tree-builder.md) を参照してください。

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
| `toggle_icons:` | no | toggle control icon の宣言的map。`by_state`、`by_depth`、`by_type` を指定できます。詳細は [toggle icon のカスタマイズ](toggle-icons.md) を参照してください。 |
| `toggle_icon_builder:` | no | toggle control content を返すcallable。`toggle_icons:` と両方指定した場合はこちらを優先します。 |
| `row_status_builder:` | no | row状態を返すcallable。 |
| `row_event_payload_builder:` | no | drag/drop transfer payloadを返すcallable。transfer専用であり、汎用row event hookではない。 |
| `persisted_state:` | no | 保存済み展開状態。 |

公開名の判断は [Public Name Decisions](public-name-decisions.md)、ARIA配置は [Accessibility Semantics](accessibility-semantics.md) を参照してください。識別子設計は [Node keys](node-keys.md) を参照してください。

## TreeView::UiConfig / UiConfigBuilder

DOM ID、toggle mode、path builder、任意の Turbo Frame target をまとめる設定objectです。

| Builder | Mode | 説明 |
|---|---|---|
| `build_turbo(...)` | `:turbo` | host appのpath builderでTurbo Stream開閉URLを作る。`turbo_frame:` を指定すると toggle link に `data-turbo-frame` を追加する。 |
| `build(...)` | `:turbo` | 後方互換のための `build_turbo` alias。`turbo_frame:` も同様に指定できる。 |
| `build_static` | `:static` | 開閉URLを持たない静的snapshot設定を作る。 |
| `build_client_side` | `:client` | Turbo endpointを使わないbrowser-local開閉設定を作る。 |

`UiConfig#mode` は `:turbo`、`:static`、`:client` を返します。`UiConfig#turbo_frame` は設定された frame target または `nil` を返します。`turbo?`、`static?`、`client?` predicateも使えます。

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
).build_turbo(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth: depth, scope: scope) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth: depth, scope: scope) },
  load_children_path_builder: ->(item, depth, scope) { children_document_path(item, depth: depth, scope: scope) },
  toggle_all_path_builder: ->(state) { documents_path(state: state) },
  turbo_frame: "documents_tree"
)
```

`turbo_frame:` を指定すると、TreeView は Turbo toggle link に `data-turbo-frame` を追加します。scope と host app 側の責務は [Turbo Frame option](turbo-frame.md) を参照してください。

### client-side

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_client_side
```

client-side modeでは、render scope内のcollapsed descendantsを初期HTMLに `hidden` 付きで描画し、bundled `tree-view-client` controllerでbrowser内の行表示を切り替えます。初期HTML量を許容できる小〜中規模tree向けです。

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
| `tree_turbo_frame(ui:)` | 解決されたUI configのTurbo Frame target、または `nil` を返す。 |
| `tree_selection_value(item, tree:, render_state:)` | checkbox value用JSONを作る。 |
| `tree_view_breadcrumb(tree, item, ...)` | breadcrumbを描画する。 |

## JavaScript entrypoint

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

主なcontroller:

- `tree-view-state`
- `tree-view-client`
- `tree-view-selection`
- `tree-view-transfer`
- `tree-view-remote-state`

## 関連docs

- [API概要](api-overview.md)
- [使い方](usage.md)
- [Turbo Frame option](turbo-frame.md)
- [Cookbook](cookbook.md)
- [PathTreeBuilder](path-tree-builder.md)
- [Accessibility Semantics](accessibility-semantics.md)
- [Error hierarchy](errors.md)
- [render log level](render-log-level.md)
- [Node keys](node-keys.md)
- [Tree diagnostics](tree-diagnostics.md)
- [Public API policy](public-api.md)
