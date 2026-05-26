# API概要

このページでは、主要な公開APIの概要を説明します。詳細な仕様は [API仕様](api.md) を参照してください。

## 中心オブジェクト

| API | 説明 |
|---|---|
| `TreeView::Tree` | records、resolver、adapterからツリー構造を作り、問い合わせる中心オブジェクトです。 |
| `TreeView::RenderState` | root、row partial、UI設定、展開状態、selection、描画範囲など、画面単位の描画状態をまとめます。 |
| `TreeView::ResourceTableRenderState` | 別の table layer が列定義や table state を持っている前提で、TreeView 向けの `RenderState` bridge を組み立てます。 |
| `TreeView::UiConfig` | static / Turbo / client-side描画で使うDOM ID、toggle mode、path builderの設定を保持します。 |
| `TreeView::UiConfigBuilder` | Rails view contextから `build_turbo`、`build_static`、`build_client_side` で `UiConfig` を組み立てます。 |
| `TreeView::VisibleRows` | 現在のrender stateで表示対象となる行を一次元化します。 |
| `TreeView::RenderWindow` | visible rowsを `offset` / `limit` で切り出し、ページング用metadataを提供します。 |
| `TreeView::PersistedState` | 保存された開閉状態を表します。 |
| `TreeView::StateStore` | host app側のmodelを通じて開閉状態を読み書きします。 |

## Error handling

TreeView は、documented された validation / configuration failure の基底 class として `TreeView::Error` を公開します。互換性のため、これは `ArgumentError` の subclass です。

host app が TreeView 固有の失敗を他の application error と分けて rescue したい場合は `TreeView::Error` を使ってください。特定の validation failure を扱う場合は、`TreeView::ConfigurationError`、`TreeView::DuplicateNodeKeyError`、`TreeView::CycleDetectedError`、`TreeView::InvalidRenderWindowError` などの documented subclass を使えます。

全体一覧と rescue 例は [Error hierarchy](errors.md) を参照してください。

## ツリー構築

### records mode

各 item が ID と親 ID を持つ場合は records mode を使います。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)
```

主な option:

| Option | 説明 |
|---|---|
| `records:` | ツリー化する item 配列。 |
| `parent_id_method:` | 親 ID を返す method 名。 |
| `id_method:` | item ID を返す method 名。既定値は `:id`。 |
| `sorter:` | root / children の並び順を決める callable。 |
| `orphan_strategy:` | records 内に親が存在しない node の扱い。 |

### resolver mode

親 ID ではなく callable で children を返したい場合は resolver mode を使います。

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)
```

### adapter mode

異種 node 混在や graph-like な構造では adapter mode を使います。

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)

tree = TreeView::Tree.new(adapter: adapter)
```

### Resource table bridge

`TreeView::ResourceTableRenderState.call(...)` は、別の table-oriented layer が visible columns や保存済み table state を管理していて、TreeView には階層行の描画 state だけを組み立てさせたい場合に使います。

```ruby
render_state = TreeView::ResourceTableRenderState.call(
  records: @projects,
  context: view_context,
  parent_id_method: :parent_project_id,
  table_key: "projects_tree",
  table_state: table_state
)
```

責務境界や連携の詳細は [Resource table bridge](resource-table-bridge.md) を参照してください。

### node keyとUI識別子

TreeViewには、関連しているが責務が異なる2種類の識別子があります。

| 層 | 設定する場所 | 使われる場所 |
|---|---|---|
| Tree node key | records mode の `id_method:`、または adapter / resolver mode の `node_key_resolver:` | tree構造のlookup、開閉状態、`expanded_keys`、`collapsed_keys`、persisted state、diagnostics。 |
| UI識別子 / DOM ID | `UiConfig` と `UiConfigBuilder` のDOM ID builder | HTML ID、Turbo target、row属性、ブラウザ側hook。 |

初期展開や折りたたみ状態に渡す値は、UI configが生成するDOM IDだけでなく、tree本体が返すnode keyと一致している必要があります。UI側のDOM ID builderを変更しても、`TreeView::Tree` がnodeを識別するkeyは変わりません。

異種node treeでは、同じ安定したkey生成方針をtree側とUI側の両方で使える形にしておくと安全です。

```ruby
node_key = ->(node) { [node.class.name, node.id].join(":") }

adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: node_key
)

tree = TreeView::Tree.new(adapter: adapter)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    expanded_keys: [node_key.call(current_section)]
  }
)
```

この形にすると、tree側の開閉状態、diagnostics、UI側のDOM targetを揃えやすくなります。期待した行が初期展開されない場合は、UIだけのDOM ID設定を変える前に、treeが返しているnode keyを確認してください。

## toggle mode

`TreeView::UiConfig` を作る時に、tree instanceごとのtoggle modeを選びます。

| Builder | Mode | 使う場面 |
|---|---|---|
| `build_turbo` / `build` | `:turbo` | host appのTurbo Stream endpointで開閉したい場合。 |
| `build_static` | `:static` | 開閉できない静的snapshotとして描画したい場合。 |
| `build_client_side` | `:client` | render scope内の全行を初期HTMLに含め、browser内だけで開閉したい場合。 |

## 描画

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

windowed renderingでは、window hashを渡します。

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

ページングmetadataが必要な場合は `tree_view_window` を使います。

```ruby
window = tree_view_window(@render_state, offset: 0, limit: 50)
window.has_next?
```

## RenderStateのgrouped option

`RenderState` は、従来の個別keyword optionとgrouped optionの両方を受け付けます。

| Group | 説明 |
|---|---|
| `initial_expansion:` | 初期展開状態、初期最大depth、展開key、折りたたみkey。 |
| `render_scope:` | 描画対象にするdepth / leaf距離の制限。 |
| `toggle_scope:` | 開閉path builderへ渡すdepth / leaf距離の制限。 |
| `selection:` | checkbox selectionの挙動とpayload設定。 |
| `lazy_loading:` | remote children読み込みの状態とscope設定。 |

個別keyword optionとgrouped optionを同時に指定した場合は、後方互換性のため個別keyword optionが優先されます。

## 選択

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

送信されたJSON値をparseする場合は、必要に応じて `TreeView.parse_selection_params` を使います。

## 親方向path helper

records modeでは、親方向のpathを確認するhelperを使えます。

| API | 説明 |
|---|---|
| `parent_for(item)` | 親itemを返します。 |
| `ancestors_for(item)` | rootから親までの祖先配列を返します。 |
| `path_for(item)` | rootから対象itemまでのpathを返します。 |
| `paths_for(items)` | 複数itemのpathを返します。 |
| `path_tree_for(items)` | rootからmatched itemへ向かう `PathTree` を作ります。 |
| `reverse_tree_for(items)` | matched itemからroot方向へ向かう `ReverseTree` を作ります。 |

## 公開helper入口

| Helper | 説明 |
|---|---|
| `tree_view_rows` | render stateからTreeView行を描画します。 |
| `tree_view_window` | render windowを作りmetadataを取得します。 |
| `tree_node_dom_id` | `UiConfig` 経由でnode DOM IDを作ります。 |
| `tree_selection_value` | checkbox value用JSONを作ります。 |
| `tree_view_breadcrumb` | 祖先pathをbreadcrumbとして描画します。 |
| `tree_view_toolbar` | TreeView bundled toolbar の HTML を描画します。 |
| `tree_view_toolbar_supported_actions` | app-owned toolbar builder が使ってよい supported toolbar action symbol を返します。 |
| `tree_view_toolbar_actions` | host app 側 toolbar markup 用の action hash 配列を返します。 |
| `tree_view_toolbar_action_metadata` | supported toolbar action 1 件分の metadata を返します。 |

## JavaScript入口

公開JavaScript入口は `tree_view/index.js` です。

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

exportされるcontroller classは安定入口として扱います。個別controller fileの配置は内部実装です。

## 詳細

- 詳細API仕様: [api.md](api.md)
- Accessibility semantics: [accessibility-semantics.md](accessibility-semantics.md)
- Error hierarchy: [errors.md](errors.md)
- Public API互換性方針: [public-api.md](public-api.md)
- Resource table bridge: [resource-table-bridge.md](resource-table-bridge.md)
- 最小利用例: [minimal-usage.md](minimal-usage.md)
- 使い方: [usage.md](usage.md)
