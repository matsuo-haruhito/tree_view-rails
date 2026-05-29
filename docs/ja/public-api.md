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
- `TreeView::NodePresenter`
- `TreeView::PathTree`
- `TreeView::PathTreeBuilder`
- `TreeView::ReverseTree`
- `TreeView::PersistedState`
- `TreeView::StateStore`
- `TreeView::Diagnostics`
- `tree_view_rows(render_state)`
- `tree_view_rows(render_state, window: { offset:, limit: })`
- `tree_view_window(render_state, offset:, limit:)`
- `tree_view_breadcrumb(tree, item, ...)`
- `tree_view_toolbar(render_state, ...)`
- `tree_view_toolbar_supported_actions`
- `tree_view_toolbar_actions(render_state, ...)`
- `tree_view_toolbar_action_metadata(render_state, action, ...)`

`TreeView::ResourceTableRenderState.call` は、別の table layer が列推論や table state を持っていて、TreeView には階層 render state の組み立てだけを任せたい場合の公開入口です。詳細は [Resource table bridge](resource-table-bridge.md) を参照してください。

## Public error surface

host app は `TreeView::Error` を rescue することで、documented された TreeView の validation / configuration failure を、他の application error と分けて扱えます。

`TreeView::Error` は既存 integration との互換性のため `ArgumentError` を継承します。新しい integration では、TreeView 固有の失敗を扱うとき `TreeView::Error` または documented subclass を優先してください。

documented public subclass は [Error hierarchy](errors.md) に整理しています。

## Public helper surface

サポート対象の helper surface は、`TreeViewHelper` と関連 helper module から公開される documented helper method names です。machine-readable な helper-method contract は `config/public_api_manifest.yml` で管理します。

host app は `TreeViewHelper::Rendering` や `TreeViewHelper::Selection` などの内部 module を直接 include せず、`TreeViewHelper` と documented helper method に依存してください。

この公開 helper surface に含まれる documented な non-toolbar helper には次があります。

- `tree_view_rows(render_state, window: nil)` は TreeView rows を描画し、opt-in の windowed rendering も扱います。
- `tree_view_window(render_state, offset:, limit:)` は visible rows 用の documented な window metadata を返します。
- `tree_node_dom_id(item_or_id, ui: @tree_ui)` は、解決された `UiConfig` を通して node DOM ID を組み立てます。
- `tree_children_container_dom_id(item, ui: @tree_ui)` は、lazy-loading で host app が持つ children container 用の安定した DOM ID を組み立てます。
- `tree_remote_state_placeholder_dom_id(item, ui: @tree_ui)` は、1 行ぶんの remote-state placeholder 用 DOM ID を組み立てます。
- `tree_remote_state_placeholder_attributes(item, state: nil, ui: @tree_ui)` は、host app の lazy-loading response で使う documented な placeholder `id` と、必要なら `data-tree-remote-state` を返します。
- `tree_selection_value(item, tree, builder = nil)` は、host app 側の selection wiring や assertion に使える documented checkbox payload contract を JSON 化します。
- `tree_view_breadcrumb(tree, item, ...)` は node の breadcrumb path を描画します。

lazy-loading の placeholder region を host app 側で持つ場合、上の 3 helper も [Lazy Loading](lazy-loading.md) で案内しているのと同じ stable helper surface に含まれます。placeholder ID や `data-tree-remote-state` attribute を手組みせず、これらの helper を使ってください。

app-owned toolbar builder では、internal constant を直接参照せず、`tree_view_toolbar_supported_actions`、`tree_view_toolbar_actions`、`tree_view_toolbar_action_metadata` を使ってください。
toolbar helper もこの公開 helper surface に含まれます。

- `tree_view_toolbar(render_state, actions: ..., labels: ..., class_name: ..., button_class_name: ..., html: ..., action_html: ...)` は TreeView bundled toolbar の HTML を描画し、toolbar container と action element へ documented な追加 HTML attribute を渡せます。
- `tree_view_toolbar_supported_actions` は app-owned toolbar builder が使ってよい supported toolbar action symbol を返します。
- `tree_view_toolbar_actions(render_state, actions: ..., labels: {})` は host app が独自 toolbar markup を組み立てるための action hash 配列を返します。
- `tree_view_toolbar_action_metadata(render_state, action, label: nil)` は 1 つの supported action 用 metadata を返します。

`html:` は `class`、`data`、`aria` などの container attribute を追加しつつ、TreeView 必須の toolbar data hook を維持します。`action_html:` は action-aware Proc、action-keyed Hash、または flat Hash で各 action link / disabled button に attribute を追加しつつ、TreeView 必須の action / disabled data hook を維持します。markup、authorization copy、追加 control を変える必要がある場合は custom rendering helper を使ってください。

公開されている toolbar action symbol は `:expand_all`、`:collapse_all`、`:collapse_all_except_current_path` です。

これらはそれぞれ tree-wide toggle state `:expanded`、`:collapsed`、`:current_path` を要求します。現在の UI mode が `toggle_all_path_builder` を持たない場合、metadata は `path: nil` と `disabled: true` を返し、fallback UI の扱いは host app 側に残ります。

`TREE_VIEW_TOOLBAR_ACTIONS`、`TREE_VIEW_TOOLBAR_LABELS`、`TREE_VIEW_TOOLBAR_STATES` のような内部 constant は実装詳細です。host app はそれらを直接参照せず、documented helper method と戻り値の metadata shape に依存してください。

`config/public_api_manifest.yml` に documented helper として載っていない method は、bundled partial から内部的に呼ばれていても public compatibility contract には含みません。

内部 module 名は、documented helper behavior を維持する限り変更される可能性があります。

## Public option surface

公開 option surface は、以下の object で documented された keyword arguments / grouped options です。

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

### RenderState grouped option keys

`TreeView::RenderState` の grouped options も public option surface の一部です。exact key set の machine-readable source of truth は `config/public_api_manifest.yml` にあり、`spec/public_api_compatibility_spec.rb` が current `TreeView::RenderState` constant と representative behavior に対してその manifest を照合します。

| Group | documented public keys | 補足 |
|---|---|---|
| `initial_expansion` | `default`, `max_depth`, `expanded_keys`, `collapsed_keys`, `current_item`, `current_key`, `auto_expand_ancestors` | 個別 keyword option と `initial_expansion:` を併用した場合でも、優先されるのは個別 keyword option です。 |
| `render_scope` | `max_depth`, `max_leaf_distance` | `TreeView::RenderState` の documented render-depth / leaf-distance control に対応します。 |
| `toggle_scope` | `max_depth_from_root`, `max_leaf_distance` | tree-wide toggle の documented depth / leaf-distance control に対応します。 |
| `selection` | `enabled`, `visibility`, `payload_builder`, `checkbox_name`, `disabled_builder`, `disabled_reason_builder`, `selected_keys`, `cascade`, `indeterminate`, `max_count` | `TreeView::RenderState::SelectionConfig` と同じ grouped key を machine-readable に追跡し、documented な flat selection keyword との対応も崩れないようにします。 |
| `lazy_loading` | `enabled`, `loaded_keys`, `scope` | documented lazy-loading row-state hook と optional な host-app scope passthrough に対応します。 |

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
- `TreeViewEventNames`
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

`TreeViewEventNames` は documented event names を machine-readable に参照するための package-root export です。host app 側で listener を配線するとき、`TreeViewEventNames.selection.change` や `TreeViewEventNames.transfer.drop` のように使うことで event name string の写経を避けられます。
`TreeViewControllerIdentifiers` は、同じ documented identifier を machine-readable な object として公開します。controller を部分登録したい host app や custom boot order を組みたい host app は、identifier string を写経せずこの export を使ってください。

`TreeViewEventNames` のうち、lazy-loading の request lifecycle 名は `hostLifecycle` にまとめています。

- `loading`
- `loaded`
- `error`
- `retry`

`TreeViewEventNames.hostLifecycle.*` は [Lazy Loading](lazy-loading.md) で説明している host app 側の dispatch surface 専用です。TreeView controller 自身が emit する remote-state event は引き続き `TreeViewEventNames.remoteState.*` に置きます。

`TreeViewControllerIdentifiers` の documented key:

- `state`
- `client`
- `selection`
- `transfer`
- `remoteState`

`tree-view-selection` controller の documented host-element value attribute も、stable な host-app wiring surface の一部です。

- `data-tree-view-selection-hidden-input-name-value`
- `data-tree-view-selection-max-count-value`
- `data-tree-view-selection-cascade-value`
- `data-tree-view-selection-indeterminate-value`

これらの attribute は host element 上で controller を設定するときに使います。row ごとの payload 生成、disabled-state 判定、checkbox visibility は `selection:` render-state builder 側の責務です。詳しくは [Selection](selection.md) と [Host app extension points](host-app-extension-points.md#selection-builders) を参照してください。

package-root の JavaScript export と bundled controller identifier の machine-readable な source of truth は `config/public_api_manifest.yml` に置きます。compatibility spec と entrypoint smoke check はその contract を参照して drift を検知します。

内部扱い:

- private controller methods
- `app/javascript/tree_view/` 以下の file layout
- documented host-app wiring surface に含まれない undocumented `data-*` attributes
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
