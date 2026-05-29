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
