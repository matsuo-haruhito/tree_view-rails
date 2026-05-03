# 使い方

## 基本構成

`tree_view` は、host app 側で取得したrecordsを `TreeView::Tree` に渡し、`TreeView::RenderState` と `tree_view/tree_row` partial を使って描画します。

## 通常Tree

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id
)
```

既定では、root / children は子孫数の昇順で並びます。

並び順を変えたい場合は `sorter:` を渡します。

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)
```

## static表示

開閉リンクを使わず、静的なツリーとして表示したい場合は `build_static` を使います。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static
```

## Turbo Stream開閉

Turbo Streamで開閉したい場合は、`build` にpath builderを渡します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "item").build(
  hide_descendants_path_builder: ->(item, depth, scope) {
    view_context.remove_descendants_item_path(item, depth: depth + 1, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    view_context.show_descendants_item_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    state == :collapsed ? view_context.items_path(collapsed: "all") : view_context.items_path
  }
)
```

## RenderState

画面単位の描画状態は `TreeView::RenderState` にまとめます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

`initial_state` は省略できます。省略した場合は global config、さらに未設定なら `:expanded` が使われます。

## Controller例

```ruby
def index
  @projects = Project.order(:name).to_a

  tree = TreeView::Tree.new(
    records: @projects,
    parent_id_method: :parent_project_id
  )

  @tree_ui = TreeView::UiConfigBuilder.new(
    context: view_context,
    node_prefix: "project"
  ).build_static

  @render_state = TreeView::RenderState.new(
    tree: tree,
    root_items: tree.root_items,
    row_partial: "projects/tree_columns",
    ui_config: @tree_ui
  )
end
```

## View例（ERB）

```erb
<table class="tree-view-table">
  <thead>
    <tr>
      <th>level</th>
      <th>name</th>
      <th>owner</th>
    </tr>
  </thead>
  <tbody>
    <%= render partial: "tree_view/tree_row",
      collection: @render_state.root_items,
      as: :item,
      locals: {
        tree: @render_state.tree,
        row_partial: @render_state.row_partial
      } %>
  </tbody>
</table>
```

## Row partial例（ERB）

```erb
<!-- app/views/projects/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

## Slimを使うhost appの場合

host app 側のviewやrow partialはSlimでも構いません。

gem本体のpartialはERBですが、host app側の `row_partial` は任意のテンプレートエンジンで実装できます。

```slim
table.tree-view-table
  thead
    tr
      th level
      th name
      th owner
  tbody
    = render partial: "tree_view/tree_row",
      collection: @render_state.root_items,
      as: :item,
      locals: {
        tree: @render_state.tree,
        row_partial: @render_state.row_partial
      }
```

```slim
/ app/views/projects/_tree_columns.html.slim
td = item.name
td = item.owner_name
```

## mode指定

`mode:` を明示する場合は、`:static` または `:turbo` のみ指定できます。

```erb
<%= render partial: "tree_view/tree_row",
  collection: @render_state.root_items,
  as: :item,
  locals: {
    tree: @render_state.tree,
    row_partial: @render_state.row_partial,
    mode: :static
  } %>
```

不正なmodeを指定すると `ArgumentError` になります。

## Global config

```ruby
TreeView.configure do |config|
  config.initial_state = :expanded
end
```
