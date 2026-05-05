# Lazy Loading

深いツリーや大量ノードを扱う画面向けに、子ノードを必要なタイミングで読み込むための hook です。

## 目的

`max_initial_depth`、`max_render_depth`、`max_leaf_distance` は初期描画量を抑えるために有効です。
一方で、利用者が閉じた階層を開いた時点で子ノードを追加取得できると、大きなツリーでも扱いやすくなります。

## 基本方針

- gem 本体は lazy loading の UI 基盤と hook を提供する
- controller、route、権限チェック、DB クエリは host app 側の責務とする
- Turbo Stream と fetch のどちらかに強く依存しすぎない
- 初期実装は data 属性とイベント hook を中心にする
- 子ノードの保存や業務処理は扱わない

## API

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "documents").build(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth:, scope:) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth:, scope:) },
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: loaded_keys,
    scope: "children"
  }
)
```

children URL は `RenderState` ではなく `UiConfig#load_children_path_builder` から供給します。`lazy_loading[:scope]` はその builder の第3引数へ渡す scope 文字列です。

## 出力する情報

lazy loading 有効時、`load_children_path_builder` がURLを返す node 行には以下のような data 属性が付きます。

```html
<tr
  data-tree-lazy="true"
  data-tree-children-url="/documents/1/children"
  data-tree-loaded="false">
</tr>
```

加えて、`loaded_keys` に含まれる node は `data-remote-state="loaded"` を持ちます。既存の `loading_builder` / `error_builder` を使う場合は、それぞれ `data-remote-state="loading"` / `data-remote-state="error"` を出力します。

## children pagination example

ページングされた children endpoint を使う場合も、TreeView gem 側は URL と state hook の受け渡しに留めます。ページサイズ、cursor、権限、DB query、次ページ有無は host app 側で判断します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "documents").build(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth:, scope:) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth:, scope:) },
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(
      item,
      depth: depth,
      scope: scope,
      page_size: 50,
      cursor: params[:cursor],
      format: :turbo_stream
    )
  },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)
```

controller 側では、親 node の children を取得し、通常の `tree_view_rows` と同じ row partial 構造で Turbo Stream を返します。

```ruby
def children
  parent = Document.find(params[:id])
  children = policy_scope(parent.children).order(:position, :id).limit(params.fetch(:page_size, 50))

  child_tree = TreeView::Tree.new(
    roots: children,
    children_resolver: ->(node) { [] },
    node_key_resolver: ->(node) { TreeView.node_key("document", node.id) }
  )

  render_state = TreeView::RenderState.new(
    tree: child_tree,
    root_items: child_tree.root_items,
    row_partial: "documents/tree_columns",
    ui_config: tree_ui,
    lazy_loading: {
      enabled: true,
      loaded_keys: [tree.node_key_for(parent)],
      scope: "children"
    }
  )

  render turbo_stream: turbo_stream.after(
    tree_node_dom_id(parent),
    helpers.tree_view_rows(render_state)
  )
end
```

「さらに読み込む」行や cursor の保持が必要な場合は、その行を host app の partial として追加してください。TreeView gem はページング戦略を固定せず、追加行の DOM ID、URL、文言、権限制御は host app 側に残します。

## 状態

最低限、以下の状態を扱えるようにします。

| 状態 | 意味 |
|---|---|
| unloaded | 子ノードをまだ読み込んでいない |
| loading | 子ノードを読み込み中 |
| loaded | 子ノードの読み込みが完了している |
| error | 子ノードの読み込みに失敗した |
| empty | 子ノードが存在しなかった |

## 責務範囲

### gem 側

- lazy loading 用 data 属性の出力
- children URL の受け渡し
- loading / error / loaded を表現するための hook
- `tree-view-remote-state` controller の state 更新 hook

### host app 側

- children endpoint の実装
- 認証・権限チェック
- 子ノードの検索・取得
- children pagination の page size / cursor / next page 判定
- Turbo Stream / HTML / JSON のレスポンス形式
- エラー時の業務固有メッセージ
- `tree-view:loading` / `tree-view:loaded` / `tree-view:error` / `tree-view:retry` の dispatch

## 既存機能との関係

### max_render_depth

`max_render_depth` は初期描画範囲を制限する機能です。
lazy loading は、描画されていない子を後から取得する機能です。

両者は併用可能です。`max_render_depth` で深いノードを省略していても、親行に `data-tree-children-url` を持たせておけば host app 側で追加入力の入口を作れます。

### selection

親子連動 selection と併用する場合、未ロードの子孫まで選択対象に含めるかは host app 側で判断します。
初期実装では DOM 上に存在する checkbox のみを対象にするのが安全です。

### persisted state

保存済み `expanded_keys` に未ロードノードが含まれる場合の追加取得タイミングは host app 側で決めます。TreeView は `loaded_keys` と remote-state data を通じて表示側の基盤だけを提供します。
