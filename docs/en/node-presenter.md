# NodePresenter

`TreeView::NodePresenter` groups node-level resolver hooks that are otherwise passed to `RenderState` one by one.

Use it when a host app has multiple node types and wants a single place to resolve row classes, data attributes, icons, badges, labels, links, tooltips, or actions.

## Basic usage

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

Pass the presenter to `RenderState`:

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

`RenderState` currently consumes these presenter hooks directly:

| Presenter hook | RenderState hook |
|---|---|
| `row_class` | `row_class_builder` |
| `row_data` | `row_data_builder` |
| `badge` | `badge_builder` |
| `icon` | `icon_builder` |

Explicit `RenderState` builders take precedence over presenter-provided builders.

```ruby
TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  node_presenter: presenter,
  badge_builder: ->(item) { item.status_label }
)
```

In this example, `badge_builder` wins over `presenter.badge`.

## Non-rendered resolvers

The presenter also supports these resolver hooks for host app use:

- `key`
- `label`
- `href`
- `tooltip`
- `actions`

TreeView does not render links, tooltips, or actions automatically. Host app row partials can call the presenter directly when they need those values.

```erb
<% presenter = render_state.node_presenter %>
<%= link_to presenter.label_for(item), presenter.href_for(item), title: presenter.tooltip_for(item) %>
```

## Responsibility boundary

`NodePresenter` is intentionally a thin adapter over existing extension points. It does not replace host app row partials and does not introduce a table/action DSL. Column and action rendering can build on top of it in a later PR.
