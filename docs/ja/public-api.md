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
- `TreeView::ResourceTableRenderState.call`
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
- `tree_view_toolbar(render_state, ...)`
- `tree_view_toolbar_actions(render_state, ...)`
- `tree_view_toolbar_action_metadata(render_state, action, ...)`

`TreeView::ResourceTableRenderState.call` は、別の table layer が列推論や table state を持っていて、TreeView には階層 render state の組み立てだけを任せたい場合の公開入口です。詳細は [Resource table bridge](resource-table-bridge.md) を参照してください。

## Public error surface

host app は `TreeView::Error` を rescue することで、documented された TreeView の validation / configuration failure を、他の application error と分けて扱えます。

`TreeView::Error` は既存 integration との互換性のため `ArgumentError` を継承します。新しい integration では、TreeView 固有の失敗を扱うとき `TreeView::Error` または documented subclass を優先してください。

documented public subclass は [Error hierarchy](errors.md) に整理しています。

## Public helper surface

サポート対象のhelper surfaceは、`TreeViewHelper` と関連helper moduleから公開される documented helper method names です。

host app は `TreeViewHelper::Rendering` や `TreeViewHelper::Selection` などの内部moduleを直接includeせず、`TreeViewHelper` と documented helper method に依存してください。

app-owned toolbar builderでは、internal constantを直接参照せず、`tree_view_toolbar_supported_actions`、`tree_view_toolbar_actions`、`tree_view_toolbar_action_metadata` を使ってください。
toolbar helper もこの公開helper surfaceに含まれます。

- `tree_view_toolbar(render_state, actions: ..., labels: ..., class_name: ..., button_class_name: ...)` は TreeView bundled toolbar の HTML を描画します。
- `tree_view_toolbar_actions(render_state, actions: ..., labels: {})` は host app が独自 toolbar markup を組み立てるための action hash 配列を返します。
- `tree_view_toolbar_action_metadata(render_state, action, label: nil)` は 1 つの supported action 用 metadata を返します。

公開されている toolbar action symbol は `:expand_all`、`:collapse_all`、`:collapse_all_except_current_path` です。

これらはそれぞれ tree-wide toggle state `:expanded`、`:collapsed`、`:current_path` を要求します。現在の UI mode が `toggle_all_path_builder` を持たない場合、metadata は `path: nil` と `disabled: true` を返し、fallback UI の扱いは host app 側に残ります。

`TREE_VIEW_TOOLBAR_ACTIONS`、`TREE_VIEW_TOOLBAR_LABELS`、`TREE_VIEW_TOOLBAR_STATES` のような内部constantは実装詳細です。host app はそれらを直接参照せず、documented helper method と戻り値の metadata shape に依存してください。

内部module名は、documented helper behaviorを維持する限り変更される可能性があります。

## Public option surface

公開option surfaceは、以下のobjectでdocumentedされたkeyword arguments / grouped optionsです。

- `TreeView::Configuration`
- `TreeView::Tree`
- `TreeView::PathTreeBuilder`
- `TreeView::RenderState`
- `TreeView::ResourceTableRenderState.call`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::RenderWindow`
- `TreeView::PersistedState`
- `TreeView::StateStore`

公開configuration optionには以下を含めます。

- `initial_state`
- `render_log_level`

公開localized display-name helperには以下を含めます。

- `TreeView.model_name_for(item_or_class, count: 1, default: nil)`
- `TreeView.attribute_name_for(item_or_class, attribute, default: nil)`
- `TreeView.type_name_for(item, count: 1, default: nil)`

公開Turbo UI optionには以下を含めます。

- `UiConfig#turbo_frame`
- `UiConfigBuilder#build_turbo(turbo_frame:)`
- `UiConfigBuilder#build(..., turbo_frame:)`

詳細は [API仕様](api.md)、[Localized names](localized-names.md)、[Turbo Frame option](turbo-frame.md) を参照してください。

## Host app extension points

host app が提供する主な拡張点は以下です。

- records or adapter data
- `PathTreeBuilder` で生成folder treeを作るための path resolver
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

公開JavaScript entrypointは `tree_view/index.js` です。

host app が使ってよい入口:

- `registerTreeViewControllers(application)`
- `TreeViewControllerIdentifiers`
- exported controller classes
  - `TreeViewStateController`
  - `TreeViewClientController`
  - `TreeViewSelectionController`
  - `TreeViewTransferController`
  - `TreeViewRemoteStateController`
- documented JavaScript events and payload keys
- documented `data-tree-view-*` integration hooks

`registerTreeViewControllers(application)` は、上記 5 つの controller export を bundled entrypoint の documented identifier 順に登録します。

`TreeViewControllerIdentifiers` は、同じ documented identifier を machine-readable な object として公開します。controller を部分登録したい host app や custom boot order を組みたい host app は、identifier string を写経せずこの export を使ってください。

`TreeViewControllerIdentifiers` の documented key:

- `state`
- `client`
- `selection`
- `transfer`
- `remoteState`

package-root の JavaScript export と bundled controller identifier の machine-readable な source of truth は `config/public_api_manifest.yml` に置きます。compatibility spec と entrypoint smoke check はその contract を参照して drift を検知します。

内部扱い:

- private controller methods
- `app/javascript/tree_view/` 以下のfile layout
- undocumented `data-*` attributes
- controller内部のDOM traversal details

## CSS and DOM surface

host app が依存してよいbrowser-facing surfaceは、documented されたCSS class、data attribute、JavaScript eventに限定します。

設定済みの Turbo toggle link から出力される `data-turbo-frame` は documented host-app integration surface です。

undocumented なCSS helper class、data attribute、DOM構造詳細、gem partial内部localsは内部実装です。

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

1. 既存APIを動かし続ける。
2. replacement APIを追加してdocumentする。
3. `CHANGELOG.md` と関連docsにdeprecation noteを書く。
4. 可能なら次 minor release まで compatibility path を維持する。

pre-`1.0` でも breaking change は意図的に扱い、migration note を残します。
