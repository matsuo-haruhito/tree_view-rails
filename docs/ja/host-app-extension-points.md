# Host app extension points

このページでは、host Rails app が TreeView を拡張・統合するための主な hook を整理します。

## 概要

TreeView は、業務固有の表示や挙動を gem 内に持ち込まず、host app 側の builder や partial で拡張できるようにしています。

主な extension point:

- `row_partial`
- `row_actions_partial`
- `row_class_builder`
- `row_data_builder`
- `badge_builder`
- `depth_label_builder`
- `row_disabled_builder`
- `row_readonly_builder`
- `row_disabled_reason_builder`
- transfer payload builders
- selection builders
- selection controller value attributes
- interactive-control markers (`data-tree-view-interactive` と `data-tree-view-ignore-*`)
- host app が所有する direction-aware stylesheet override
- lazy loading path builders
- Turbo path builders

row ごとの payload、disabled state、selected keys、checkbox visibility は render-state 側の selection builders で設定します。描画済み checkbox の同期や制約は host-element の selection controller value attributes で設定し、custom row control を TreeView の keyboard / row-click / drag から外したい場合は interactive-control markers を使います。host app が RTL、vertical writing、design-system-specific な current-row / hierarchy cue を必要とする場合は、TreeView の documented hook を維持したうえで、stylesheet override の境界を [Direction-aware styling boundary](direction-aware-styling.md) で確認してください。

`icon_builder` の compatibility status を含む公開名の判断は [Public Name Decisions](public-name-decisions.md) を参照してください。

## hook 逆引き

host app integration point をどの hook で扱うか迷うときは、この表から辿ります。

| 目的 | Extension point | 詳細 guide |
|---|---|---|
| 業務固有の cell や control を描画する | `row_partial`; 共通の row label、badge、tooltip、action には `TreeView::NodePresenter` を使える。必要に応じて custom widget に `data-tree-view-interactive`、`data-tree-view-ignore-keyboard`、`data-tree-view-ignore-row-click`、`data-tree-view-ignore-drag` を付ける | [NodePresenter row partial patterns](node-presenter-row-partials.md)、[Localized names](localized-names.md)、[使い方](usage.md#行内のinteractive-control)、[Drag and Drop](drag-and-drop.md#draggable-row内のinteractive-control) |
| 行単位の action link、action menu、context-menu-like surface を置く | slot には `row_actions_partial` を使う。TreeView の keyboard / row-click / drag を起動させたくない custom menu control には `data-tree-view-interactive` またはより狭い ignore marker を付ける | [Cookbook](cookbook.md#row_actions_partialで行action-linkを追加する)、[Form と編集行](form-editing.md#per-row-edit-pattern)、[使い方](usage.md#行内のinteractive-control) |
| host app 固有の row metadata を足す | host app 所有の data attribute は `row_data_builder`; TreeView はその後に lazy-loading、row status、transfer、client-mode data を merge する | [Row status](row-status.md)、[Drag and Drop](drag-and-drop.md) |
| 行全体を disabled / readonly として表す | `row_disabled_builder`、`row_readonly_builder`、`row_disabled_reason_builder`; TreeView が documented な row status class/data 属性を出す | [Row status](row-status.md) |
| drag/drop transfer data を提供する | `row_event_payload_builder`; TreeView が payload を `data-tree-transfer-payload` に serialize し、`data-tree-transfer-node-key` を足す。transfer controller は `data-tree-transfer-disabled="true"` の行を skip する | [Drag and Drop](drag-and-drop.md)、[JavaScript event contract](js-events.md#transfer-events) |
| selection payload や row ごとの selection state を設定する | `payload_builder`、`disabled_builder`、`disabled_reason_builder`、`selected_keys`、`visibility` などの render-state `selection:` option | [Selection](selection.md)、[Row status](row-status.md#selectionとの違い) |
| 描画済み row に対する selection controller の挙動を設定する | `data-tree-view-selection-hidden-input-name-value`、`data-tree-view-selection-max-count-value`、`data-tree-view-selection-cascade-value`、`data-tree-view-selection-indeterminate-value` などの host-element `tree-view-selection` value attribute | [Selection](selection.md#通常-form-submit-向けのhidden-input-sync)、[JavaScript event contract](js-events.md#selection-events) |
| direction-aware な visual cue を調整する | current-row cue、hierarchy connector、toggle spacing、RTL、vertical writing に対する host-app stylesheet override。TreeView の documented hook は維持する | [Direction-aware styling boundary](direction-aware-styling.md)、[TreeView mockups](../mockups/README.md) |
| tree 全体の toolbar control を描画する | `tree_view_toolbar`、`tree_view_toolbar_actions`、`tree_view_toolbar_supported_actions`; TreeView は helper / action surface を描画し、route、authorization、state 保存、最終的な action policy は host app が担当する | [Toolbar helper](toolbar.md)、[使い方](usage.md#turbo-expandcollapse-の最小構成) |
| records mode の breadcrumb path を描画する | `tree_view_breadcrumb`; TreeView は records mode の path を取得して描画し、現在 item、route label、authorization、layout placement、custom navigation behavior は host app が担当する | [Breadcrumb](breadcrumb.md)、[Troubleshooting](troubleshooting.md) |
| expanded state を保存・復元する | `TreeView::PersistedState`、`TreeView::StateStore`、generated persisted-state wiring; TreeView は storage helper を提供し、owner lookup、authorization、callback、retry policy、save/reset endpoint は host app が担当する | [Persisted State](persisted-state.md)、[JavaScript event contract](js-events.md#state-events) |
| visible row window を描画する | `tree_view_window`、`TreeView::RenderWindow`、`TreeView::VisibleRows`; TreeView は既に visible な row を slice し、query、paging control、cursor、infinite scroll、business pagination policy は host app が担当する | [Windowed Rendering](windowed-rendering.md)、[Render Scale](render-scale.md) |
| Turbo expand/collapse URL を作る | `show_descendants_path_builder`; route、controller、authorization、Turbo Stream response は host app が所有する | [Turbo Frame option](turbo-frame.md)、[使い方](usage.md#turbo-mode) |
| lazy-loading children URL を作る | `load_children_path_builder`; children query、route policy、authorization、返す partial shape は host app が所有する | [Lazy Loading](lazy-loading.md)、[Children Pagination](children-pagination.md) |

## row_partial

業務固有の columns は host app partial で描画します。

```ruby
row_partial: "documents/tree_columns"
```

```erb
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

複数の row partial で同じ label、tooltip、badge、href、row data、action resolver を使いたい場合は `TreeView::NodePresenter` を使います。表示する model 名、attribute 名、node type 名を Rails / I18n に合わせたい resolver では [Localized names](localized-names.md) を使えます。実際の cell、control、authorization、formatting、domain-specific な action wiring は引き続き host app が担当します。

この partial には、input、select、button、link、inline editable label など、host app 側の control も配置できます。TreeView は native interactive control から発生した event では、keyboard navigation や transfer drag start を実行しません。Custom control では、`data-tree-view-interactive="true"` または `data-tree-view-ignore-keyboard="true"`、`data-tree-view-ignore-row-click="true"`、`data-tree-view-ignore-drag="true"` のようなより狭い marker を付けます。

```erb
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
  <%= link_to "Edit", edit_document_path(item) %>
  <span data-tree-view-interactive="true">Custom picker</span>
</td>
```

詳しい row control 例は [使い方](usage.md#行内のinteractive-control) を参照してください。

これらの marker を静的に見比べたいときは、広い interactive marker と keyboard / row-click / drag 用の狭い marker の役割差分を [interactive-marker-behaviors.html](../mockups/interactive-marker-behaviors.html) で確認し、draggable row の中で native control と drag-safe custom widget がどう共存するかは [drag-interactive-controls.html](../mockups/drag-interactive-controls.html) を参照してください。

## Row action menu と context-menu-like surface

行単位の link、button、action menu、context-menu-like surface を置きたい場合は `row_actions_partial` を使います。TreeView は row slot と通常の row locals を渡すだけで、context menu component、menu state machine、authorization policy、route contract、confirm 文言、persistence workflow は提供しません。

menu trigger と menu items は host app 側の markup に置いてください。trigger が native button / link ではない custom widget の場合は、`data-tree-view-interactive="true"` を付け、TreeView の keyboard navigation や transfer drag start が app-owned control として扱うようにします。menu trigger の近くに drag handle がある場合など、特定の挙動だけを無視したいときは `data-tree-view-ignore-drag="true"` のような狭い marker を使います。

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td class="document-actions">
  <button type="button" data-tree-view-interactive="true" data-controller="menu">
    Actions
  </button>
  <%= link_to "Show", document_path(item), data: { tree_view_interactive: true } %>
</td>
```

どの action を出すか、現在 user が実行できるか、破壊的 action をどう確認するか、menu state をどこに持つか、送信後にどの controller が処理するかは host app の責務です。context-menu-like UI は、TreeView が提供する product workflow ではなく、TreeView の slot と documented interaction marker を host app が組み合わせるものとして扱ってください。

## row class / data builders

```ruby
row_class_builder: ->(document) {
  ["document-row", ("is-current" if document == current_document)]
},
row_data_builder: ->(document) {
  { document_id: document.id }
}
```

## visual builders

row badge / marker 表示には `badge_builder` を使います。`icon_builder` は compatibility alias として利用可能ですが、新しい code や examples では `badge_builder` を推奨します。

```ruby
badge_builder: ->(document) { document.status },
depth_label_builder: ->(_document, context) { "Level #{context.depth}" }
```

## row status builders

host app が行全体の disabled / readonly state を表したい場合は、専用の row status builders を使います。

```ruby
row_disabled_builder: ->(document) { document.archived? },
row_readonly_builder: ->(document) { document.locked? },
row_disabled_reason_builder: ->(document) { document.archived? ? "archived" : nil }
```

TreeView はこれらの builder を評価し、documented な status class/data 属性を `row_class_builder` / `row_data_builder` と結合します。業務ルール、操作制御、reason の表示は host app 側の責務です。完全な contract と selection state との比較は [Row status](row-status.md) を参照してください。

## transfer payload builders

`row_event_payload_builder` は transfer 専用です。drag/drop transfer data として serialize される payload を返します。汎用 row event hook ではありません。

```ruby
row_event_payload_builder: ->(document) {
  { id: document.id, key: tree.node_key_for(document) }
}
```

TreeView は返された payload を transfer 対象の各 row に `data-tree-transfer-payload` として描画し、`data-tree-transfer-node-key` も追加します。`tree-view-transfer` controller はそれらの属性を読んで transfer event を dispatch し、`data-tree-transfer-disabled="true"` が付いた行は skip します。row wiring、transfer event、host app の責務範囲は [Drag and Drop](drag-and-drop.md) を参照してください。

## selection builders

```ruby
selection: {
  enabled: true,
  payload_builder: ->(document) { { id: document.id, name: document.name } }
}
```

`selection:` 設定は、`TreeView::RenderState` 内で row ごとの payload 生成、disabled-state 判定、selected keys、checkbox visibility を決める側の設定です。

host element に `tree-view-selection` controller を設定するときは、次の documented value attribute が stable な wiring surface に含まれます。

- `data-tree-view-selection-hidden-input-name-value`: 最寄り form への hidden input sync
- `data-tree-view-selection-max-count-value`: client-side の最大選択数制限
- `data-tree-view-selection-cascade-value`: 描画済み行どうしの cascade 挙動
- `data-tree-view-selection-indeterminate-value`: 親 checkbox の mixed-state 更新

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-hidden-input-name-value="selected_nodes[]"
  data-tree-view-selection-max-count-value="10"
  data-tree-view-selection-cascade-value="true"
  data-tree-view-selection-indeterminate-value="true">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

row ごとの意味づけは render-state 側の `selection:` option で行い、Stimulus controller が既に描画された checkbox をどう同期・制約するかは host-element value attribute 側で設定します。event や挙動の詳細は [Selection](selection.md) を参照してください。

Selection disabled state は checkbox に対する状態です。行全体の disabled / readonly state は row status builders、drag/drop transfer の可否は transfer row data hooks の領域です。これらの境界を比較するときは [Row status](row-status.md#selectionとの違い) と [Drag and Drop](drag-and-drop.md) を参照してください。

## path builders

Turbo や lazy loading の URL は host app が作ります。

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
},
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| extension hook definitions | yes | no |
| builder invocation | yes | provides builders |
| business UI | no | yes |
| interactive-control guards | yes | marks custom widgets when needed |
| routes and controllers | no | yes |
| authorization | no | yes |
| CSS/design system | documented baseline hooks only | direction-aware stylesheet override を含む最終 visual policy |
