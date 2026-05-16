# NodePresenter

`TreeView::NodePresenter` は、`RenderState` に個別に渡していた node-level resolver hook をまとめるための薄いadapterです。

複数種類のnodeを扱うhost appで、row class、data属性、icon、badge、label、link、tooltip、actions などの解決場所をまとめたい場合に使います。

## 基本例

```ruby
presenter = TreeView::NodePresenter.define do
  label { |item| item.title }
  href { |item| Rails.application.routes.url_helpers.document_path(item) }
  tooltip { |item| item.summary }
  row_class { |item| "tree-node--#{item.node_type}" }
  row_data { |item| { node_type: item.node_type } }
  icon { |item| item.node_type }
  badge { |item| item.unread? ? "unread" : nil }
  actions { |item| [:open, :download] if item.file? }
end
```

`RenderState` に渡します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  node_presenter: presenter
)
```

## RenderState integration

現時点で `RenderState` が直接利用する hook は以下です。

| Presenter hook | RenderState hook |
|---|---|
| `row_class` | `row_class_builder` |
| `row_data` | `row_data_builder` |
| `badge` | `badge_builder` |
| `icon` | `icon_builder` |

明示的に `RenderState` builder を指定した場合は、presenter由来のbuilderより優先されます。

## row partial からの利用

`key`, `label`, `href`, `tooltip`, `actions` は TreeView が自動描画しません。host app の row partial から直接呼び出してください。

```erb
<% presenter = render_state.node_presenter %>
<%= link_to presenter.label_for(item), presenter.href_for(item), title: presenter.tooltip_for(item) %>
```

## 責務境界

`NodePresenter` は既存 extension point の薄いadapterです。host app row partial を置き換えず、table/action DSL もまだ提供しません。Column / Action DSL は後続PRでこの上に積み上げられます。
