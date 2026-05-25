# Public API

このページでは、host Rails app が直接使ってよい公開API、内部API、互換性方針を整理します。

## 安定した公開入口

host app が直接使ってよい主な入口は以下です。

- `TreeView.configure`
- `TreeView.configuration`
- `TreeView.reset_configuration!`
- `TreeView.parse_selection_params`
- `TreeView.node_key`
- `TreeView.model_name_for`
- `TreeView.attribute_name_for`
- `TreeView.type_name_for`
- `TreeView::Error`
- `TreeView::ConfigurationError`
- `TreeView::InvalidTreeError`
- `TreeView::DuplicateNodeKeyError`
- `TreeView::CycleDetectedError`
- `TreeView::InvalidRenderWindowError`
- `TreeView::LocalizedNames`
- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::VisibleRows`
- `TreeView::RenderWindow`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::GraphAdapter`
- `TreeView::PathTree`
- `TreeView::PathTreeBuilder`
- `TreeView::ReverseTree`
- `TreeView::PersistedState`
- `TreeView::StateStore`
- `tree_view_rows(render_state)`
- `tree_view_rows(render_state, window: { offset:, limit: })`
- `tree_view_window(render_state, offset:, limit:)`
- `tree_view_breadcrumb(tree, item, ...)`

## Public error surface

host app は `TreeView::Error` を rescue することで、documented された TreeView の validation / configuration failure を、他の application error と分けて扱えます。

`TreeView::Error` は既存 integration との互換性のため `ArgumentError` を継承します。新しい integration では、TreeView 固有の失敗を扱うとき `TreeView::Error` または documented subclass を優先してください。

documented public subclass は [Error hierarchy](errors.md) に整理しています。

## Public helper surface

サポート対象の helper surface は、`TreeViewHelper` と関連 helper module から公開される documented helper method names です。

host app は `TreeViewHelper::Rendering` や `TreeViewHelper::Selection` などの内部 module を直接 include せず、`TreeViewHelper` と documented helper method に依存してください。

内部 module 名は、documented helper behavior を維持する限り変更される可能性があります。

## Public option surface

公開 option surface は、以下の object で documented された keyword arguments / grouped options です。

- `TreeView::Configuration`
- `TreeView::Tree`
- `TreeView::PathTreeBuilder`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::RenderWindow`
- `TreeView::PersistedState`
- `TreeView::StateStore`

公開 configuration option には以下を含めます。

- `initial_state`
- `render_log_level`

公開 localized display-name helper には以下を含めます。

- `TreeView.model_name_for(item_or_class, count: 1, default: nil)`
- `TreeView.attribute_name_for(item_or_class, attribute, default: nil)`
- `TreeView.type_name_for(item, count: 1, default: nil)`

公開 Turbo UI option には以下を含めます。

- `UiConfig#turbo_frame`
- `UiConfigBuilder#build_turbo(turbo_frame:)`
- `UiConfigBuilder#build(..., turbo_frame:)`

詳細は [API仕様](api.md)、[Localized names](localized-names.md)、[Turbo Frame option](turbo-frame.md) を参照してください。

## Host app extension points

host app が提供する主な拡張点は以下です。

- records or adapter data
- `PathTreeBuilder` で生成 folder tree を作るための path resolver
- localized model / attribute / node type display name 用の I18n translations
- `row_partial`
- Turbo mode path builders
- `turbo_frame:` による任意の Turbo Frame target
- row class / data builders
- row event payload builders
- selection payload / disabled builders
- hidden message / breadcrumb / depth label / row status builders
- lazy loading path builders and remote-state handling
- persisted state storage model

## JavaScript surface

公開 JavaScript entrypoint は `tree_view/index.js` です。

host app が使ってよい入口:

- `registerTreeViewControllers(application)`
- exported controller classes
  - `TreeViewStateController`
  - `TreeViewClientController`
  - `TreeViewSelectionController`
  - `TreeViewTransferController`
  - `TreeViewRemoteStateController`
- documented JavaScript events and payload keys
- documented `data-tree-view-*` integration hooks

`registerTreeViewControllers(application)` は、上記 5 つの controller export を bundled entrypoint の documented identifier 順に登録します。

内部扱い:

- private controller methods
- `app/javascript/tree_view/` 以下の file layout
- undocumented `data-*` attributes
- controller 内部の DOM traversal details

## CSS and DOM surface

host app が依存してよい browser-facing surface は、documented された CSS class、data attribute、JavaScript event に限定します。

設定済みの Turbo toggle link から出力される `data-turbo-frame` は documented host-app integration surface です。

undocumented な CSS helper class、data attribute、DOM 構造詳細、gem partial 内部 locals は内部実装です。

## Breaking change criteria

以下は breaking change として扱います。

- documented class / module / helper / method の削除・rename
- documented option の削除・rename
- rendered output や parsed params に影響する documented default 変更
- flat options と grouped options の documented priority 変更
- documented JavaScript event name / payload key 変更
- documented CSS/data hooks の削除
- `tree_view_rows(render_state)` の documented behavior 変更
- selection / row event payload shape 変更
- persisted state semantics 変更
- documented public error class の削除、または documented error を `TreeView::Error` hierarchy の外へ移すこと

以下は通常 breaking change ではありません。

- backward-compatible default を持つ optional keyword 追加
- documented class を維持した CSS class 追加
- data attribute 追加
- event detail key 追加
- 新しく documented した validation / configuration failure 向けの `TreeView::Error` subclass 追加
- internal helper module refactor
- `tree_view/index.js` exports を維持した controller file 移動
- README / docs 導線を維持した docs 構造変更

## Deprecation policy

breaking change が必要だが急がない場合:

1. 既存 API を動かし続ける。
2. replacement API を追加して document する。
3. `CHANGELOG.md` と関連 docs に deprecation note を書く。
4. 可能なら次 minor release まで compatibility path を維持する。

pre-`1.0` でも breaking change は意図的に扱い、migration note を残します。
