# Lazy Loading 設計方針

深いツリーや大量ノードを扱う画面向けに、子ノードを必要なタイミングで読み込むための設計方針です。

## 目的

`max_initial_depth`、`max_render_depth`、`max_leaf_distance` は初期描画量を抑えるために有効です。
一方で、利用者が閉じた階層を開いた時点で子ノードを追加取得できると、大きなツリーでも扱いやすくなります。

## 基本方針

- gem 本体は lazy loading の UI 基盤と hook を提供する
- controller、route、権限チェック、DB クエリは host app 側の責務とする
- Turbo Stream と fetch のどちらかに強く依存しすぎない
- 初期実装は data 属性とイベント hook を中心にする
- 子ノードの保存や業務処理は扱わない

## 想定 API

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    children_url_builder: ->(item) { document_children_path(item) }
  }
)
```

個別引数として以下のような API も検討できます。

```ruby
lazy: true,
children_url_builder: ->(item) { document_children_path(item) }
```

ただし、将来 `loading_message` や `error_message` を追加しやすいように、grouped option を優先候補とします。

## 出力する情報

lazy loading 有効時、未描画の子を持つ node には以下のような data 属性を付与する想定です。

```html
<tr
  data-tree-lazy="true"
  data-tree-children-url="/documents/1/children"
  data-tree-loaded="false">
</tr>
```

実際の属性名は既存の `tree-view-state` / `tree-view-selection` と整合させて決めます。

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
- loading / error / empty を表現するための hook
- Stimulus event の発火

### host app 側

- children endpoint の実装
- 認証・権限チェック
- 子ノードの検索・取得
- Turbo Stream / HTML / JSON のレスポンス形式
- エラー時の業務固有メッセージ

## 既存機能との関係

### max_render_depth

`max_render_depth` は初期描画範囲を制限する機能です。
lazy loading は、描画されていない子を後から取得する機能です。

両者は併用可能ですが、lazy loading 有効時は `max_render_depth` で省略されたノードに children URL を付与できる必要があります。

### selection

親子連動 selection と併用する場合、未ロードの子孫まで選択対象に含めるかは host app 側で判断します。
初期実装では DOM 上に存在する checkbox のみを対象にするのが安全です。

### persisted state

保存済み `expanded_keys` に未ロードノードが含まれる場合、初期表示時にその階層を自動読み込みするかは別途検討します。
初期実装では、保存済み状態の復元と lazy loading は疎結合に保ちます。

## 実装順序

1. lazy loading option の設計を docs に固定する
2. `RenderState` に lazy loading option を追加する
3. node 行に children URL と loaded 状態の data 属性を出力する
4. Stimulus hook を追加する
5. Turbo Stream / fetch のサンプルを docs に追加する
