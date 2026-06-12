# Resource table bridge

`TreeView::ResourceTableRenderState` は、列推論や保存済みtable stateを別のtable layerが持っている場合に、TreeView側が階層行の描画だけを担当しやすくするための小さなbridgeです。

TreeViewはActive Recordのカラム推論を行いません。カラム推論、ラベル解決、保存済み表示設定はhost appまたはRails Table Preferencesのようなtable layerが担当します。

## 基本例

```ruby
render_state = TreeView::ResourceTableRenderState.call(
  records: @projects,
  context: view_context,
  table_key: "projects_tree",
  parent_id_method: :parent_project_id,
  table_state: table_state
)
```

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(render_state) %>
  </tbody>
</table>
```

default row partialは `tree_view/resource_table_row` です。`table_state["visible_columns"]` が渡されていればそれを使い、なければ `columns` を参照します。`ResourceTableRenderState` はどちらも render state 経由で row partial に渡します。

## public call option contract

`ResourceTableRenderState.call` は manifest-backed な public bridge です。required keyword は `records:` と `context:` です。

公開 contract として扱う optional bridge keyword は以下です。

- `row_partial:`
- `parent_id_method:`
- `id_method:`
- `table_key:`
- `columns:`
- `table_state:`
- `ui_config:`

その他の keyword option は `**render_options` として受け取り、`TreeView::RenderState` に渡します。これらは resource-table 専用 contract ではなく、既存の RenderState option surface として扱ってください。たとえば `initial_expansion:`、`selection:`、`lazy_loading:` のような grouped option は RenderState 側の docs と manifest section が責務を持ちます。

### row data composition

host app が authorization hint、row state、table layer integration 用の追加 data を行に持たせたい場合は、`ResourceTableRenderState.call` に `row_data_builder:` を渡せます。host builder は既存 `RenderState` と同じ1引数の形でも使えますし、depth などの描画contextが必要な場合は第2引数の row context も受け取れます。

resource-table bridge の data は予約済みで、TreeView が所有します。host data を先に merge し、その後で bridge が次の key を最後に書き込みます。

- `rails_ui_row`
- `tree_view_resource_table_row`
- `rails_table_preferences_table_key`

この優先順位により、host app は `resource_id`、`business_state`、`can_edit` のような app-owned key を追加できます。一方で、bridge-owned hook が host data によって誤って消えることはありません。host builder が `nil` を返した場合は空 data として扱います。bridge は authorization、business action、table preference state を実装せず、row data composition の境界だけを安定させます。

## Rails Table Preferencesとの連携

Rails Table Preferencesのようなtable layerがActive Recordからカラムを推論し、保存済み設定を `table_state` にmergeしてからTreeViewへ渡す想定です。

```ruby
columns = RailsTablePreferences::Adapters::ActiveRecordColumns.call(model: Project)
table_state = RailsTablePreferences::TableState.call(settings: settings, columns: columns)

render_state = TreeView::ResourceTableRenderState.call(
  records: @projects,
  context: view_context,
  parent_id_method: :parent_project_id,
  table_key: "projects_tree",
  table_state: table_state,
  columns: columns
)
```

責務分離は以下です。

- Rails Table Preferences: カラム推論、ラベル解決、保存済みtable state、preference UI
- TreeView: tree構造と階層行の描画
- host app: 必要に応じたpartial差し替え、query、認可、業務処理

通常 table と tree-table の両方を使う host app では、まずこのページで TreeView が担当する範囲を決め、column state、width、preset、export metadata、preference UI の詳細は table preferences layer 側の docs を確認してください。TreeView には row hierarchy、visible row order、expansion state、rendering hook を任せ、table layer には table 全体の column / preference state を任せると、責務が重複しにくくなります。

### 責務境界

TreeView と table preferences layer を組み合わせる場合は、永続化する state を目的別に分けてください。

| 担当 | 担当するもの | 担当しないもの |
| --- | --- | --- |
| TreeView | row hierarchy、visible row order、expansion state、selection state、lazy-loading hook、render hook | column visibility、column order、column width、filter、sort、preset |
| table preferences layer | column key、visibility、order、width、filter、sort、preset state | node key、row identity、expansion state、selection state |
| host app | query execution、authorization、preload policy、business action、partial差し替え | gem間で暗黙に共有する hidden state |

node key と row DOM id は TreeView 側の identity として扱います。`data-rails-table-preferences-column-key` は table column 側の identity です。同じ row markup の中に出てきても、互いの代用として使わないでください。

### empty row の colspan 方針

TreeView の組み込み empty row は、TreeView が host app の実カラム数を所有または推論しない前提で、広めの `colspan="999"` fallback を使います。これにより、selection column、row action、table preferences layer の列がある画面でも no-root / no-results message を table body 全体に逃がせます。

この fallback は column ownership を意味しません。実際の column count、caption、summary、周辺 table layout、custom empty-state copy / CTA は引き続き host app または table layer の責務です。正確な colspan が必要な画面では、TreeView と table column state を暗黙に結合せず、app-owned empty row または custom partial 側で扱ってください。

shared hierarchy rows と、より多い visible column / より少ない visible column の比較を host app 側の table logic なしで見たい場合は [resource-table-bridge.html](../mockups/resource-table-bridge.html) を参照してください。

## 使うべき場面

通常のTreeViewでは、従来通り `TreeView::RenderState` を直接使って問題ありません。

`ResourceTableRenderState` は、次のような場合に使います。

- 通常tableとtree tableで同じ列定義やtable stateを共有したい
- Rails Table Preferencesなどの別layerが `visible_columns` を決めている
- TreeViewには階層構造とrow renderingだけを任せたい

## 使わない方がよい場面

- TreeView単体でシンプルなtreeを描画するだけの場合
- カラム表示設定や保存済みtable stateを使わない場合
- row partialを完全にhost app側で個別実装している場合
