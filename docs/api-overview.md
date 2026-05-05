# API overview / API概要

This page gives a bilingual overview of the main public APIs. See [API reference](api.md) for the full detailed reference.

このページでは、主要な公開APIの概要を日英で説明します。詳細な仕様は [API reference](api.md) を参照してください。

## Core objects / 中心オブジェクト

| API | English | 日本語 |
|---|---|---|
| `TreeView::Tree` | Builds and queries tree structures from records, resolvers, or adapters. | records、resolver、adapterからツリー構造を作り、問い合わせる中心オブジェクトです。 |
| `TreeView::RenderState` | Holds screen-level rendering state such as roots, row partial, UI config, expansion, selection, and render scope. | root、row partial、UI設定、展開状態、selection、描画範囲など、画面単位の描画状態をまとめます。 |
| `TreeView::UiConfig` | Stores DOM ID and path-building behavior for static or Turbo rendering. | static / Turbo描画で使うDOM IDやpath builderの設定を保持します。 |
| `TreeView::UiConfigBuilder` | Builds `UiConfig` objects from a Rails view context. | Rails view contextから `UiConfig` を組み立てます。 |
| `TreeView::VisibleRows` | Flattens currently visible rows from a render state. | 現在のrender stateで表示対象となる行を一次元化します。 |
| `TreeView::RenderWindow` | Slices visible rows by `offset` and `limit` and exposes pagination metadata. | visible rowsを `offset` / `limit` で切り出し、ページング用metadataを提供します。 |
| `TreeView::PersistedState` | Represents persisted expansion state. | 保存された開閉状態を表します。 |
| `TreeView::StateStore` | Loads and saves persisted state through a host app model. | host app側のmodelを通じて開閉状態を読み書きします。 |

## Tree construction / ツリー構築

### records mode

Use records mode when each item has an ID and a parent ID.

各itemがIDと親IDを持つ場合は records mode を使います。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)
```

Important options:

主なoption:

| Option | English | 日本語 |
|---|---|---|
| `records:` | Items to render as a tree. | ツリー化するitem配列。 |
| `parent_id_method:` | Method name that returns the parent ID. | 親IDを返すmethod名。 |
| `id_method:` | Method name that returns the item ID. Defaults to `:id`. | item IDを返すmethod名。既定値は `:id`。 |
| `sorter:` | Callable used for root and child ordering. | root / children の並び順を決めるcallable。 |
| `orphan_strategy:` | Strategy for records whose parent is missing from the record set. | records内に親が存在しないnodeの扱い。 |

### resolver mode

Use resolver mode when children come from a callable instead of parent IDs.

親IDではなくcallableでchildrenを返したい場合は resolver mode を使います。

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)
```

### adapter mode

Use adapter mode for heterogeneous or graph-like structures.

異種node混在やgraph-likeな構造では adapter mode を使います。

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)

tree = TreeView::Tree.new(adapter: adapter)
```

## Rendering / 描画

The recommended rendering entrypoint is `tree_view_rows(render_state)`.

推奨される描画入口は `tree_view_rows(render_state)` です。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

```erb
<tbody>
  <%= tree_view_rows(@render_state) %>
</tbody>
```

For windowed rendering, pass a window hash:

windowed renderingでは、window hashを渡します。

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

For pagination metadata, use `tree_view_window`:

ページングmetadataが必要な場合は `tree_view_window` を使います。

```ruby
window = tree_view_window(@render_state, offset: 0, limit: 50)
window.has_next?
```

## RenderState option groups / RenderStateのgrouped option

`RenderState` accepts both legacy flat keyword options and grouped options.

`RenderState` は、従来の個別keyword optionとgrouped optionの両方を受け付けます。

| Group | English | 日本語 |
|---|---|---|
| `initial_expansion:` | Default expansion, max initial depth, expanded keys, and collapsed keys. | 初期展開状態、初期最大depth、展開key、折りたたみkey。 |
| `render_scope:` | Depth and leaf-distance limits for what is rendered. | 描画対象にするdepth / leaf距離の制限。 |
| `toggle_scope:` | Depth and leaf-distance limits passed to toggle path builders. | 開閉path builderへ渡すdepth / leaf距離の制限。 |
| `selection:` | Checkbox selection behavior and payload options. | checkbox selectionの挙動とpayload設定。 |
| `lazy_loading:` | Remote children state and scope options. | remote children読み込みの状態とscope設定。 |

Flat keyword options take precedence when both forms are provided.

個別keyword optionとgrouped optionを同時に指定した場合は、後方互換性のため個別keyword optionが優先されます。

## Selection / 選択

TreeView can render checkbox selection, but the host app owns the business action.

TreeViewはcheckbox selectionを描画できますが、業務処理はhost app側の責務です。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    visibility: :leaves
  }
)
```

Use `TreeView.parse_selection_params` to parse submitted JSON values when appropriate.

送信されたJSON値をparseする場合は、必要に応じて `TreeView.parse_selection_params` を使います。

## Path helpers / 親方向path helper

Records mode provides helpers for inspecting parent paths.

records modeでは、親方向のpathを確認するhelperを使えます。

| API | English | 日本語 |
|---|---|---|
| `parent_for(item)` | Returns the parent item. | 親itemを返します。 |
| `ancestors_for(item)` | Returns ancestors from root to parent. | rootから親までの祖先配列を返します。 |
| `path_for(item)` | Returns the path from root to item. | rootから対象itemまでのpathを返します。 |
| `paths_for(items)` | Returns paths for multiple items. | 複数itemのpathを返します。 |
| `path_tree_for(items)` | Builds a root-to-match `PathTree`. | rootからmatched itemへ向かう `PathTree` を作ります。 |
| `reverse_tree_for(items)` | Builds a match-to-root `ReverseTree`. | matched itemからroot方向へ向かう `ReverseTree` を作ります。 |

## Public helper entrypoints / 公開helper入口

| Helper | English | 日本語 |
|---|---|---|
| `tree_view_rows` | Render TreeView rows from a render state. | render stateからTreeView行を描画します。 |
| `tree_view_window` | Build a render window and expose metadata. | render windowを作りmetadataを取得します。 |
| `tree_node_dom_id` | Build a node DOM ID through `UiConfig`. | `UiConfig` 経由でnode DOM IDを作ります。 |
| `tree_selection_value` | Build a JSON checkbox value. | checkbox value用JSONを作ります。 |
| `tree_view_breadcrumb` | Render an ancestor breadcrumb. | 祖先pathをbreadcrumbとして描画します。 |

## JavaScript entrypoint / JavaScript入口

The public JavaScript entrypoint is `tree_view/index.js`.

公開JavaScript入口は `tree_view/index.js` です。

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Exported controller classes are documented as the stable entrypoints. Individual controller file layout is internal.

exportされるcontroller classは安定入口として扱います。個別controller fileの配置は内部実装です。

## More detail / 詳細

- Full API reference: [api.md](api.md)
- Public API compatibility policy: [public-api.md](public-api.md)
- Minimal usage: [minimal-usage.md](minimal-usage.md)
- Main usage guide: [usage.md](usage.md)
