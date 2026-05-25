# NodePresenter row partial patterns

This cookbook shows how to use `TreeView::NodePresenter` from host-app row partials without adding a generic Column / Action DSL to TreeView.

The goal is to keep shared tree concepts in the gem and leave app-specific table cells, actions, permissions, formatting, modals, downloads, and inline editing in the host app.

## Why not a Column / Action DSL yet?

Columns and actions vary quickly by product:

- authorization and policy checks
- download, preview, edit, delete, and modal actions
- responsive layout
- dropdowns and bulk actions
- inline editing and forms
- date, status, and domain-specific formatting

Those concerns are often not tree-specific. TreeView should only absorb abstractions that are common across many tree UIs.

## Recommended split

TreeView provides reusable structure and resolvers:

- tree structure
- generated path trees
- current path expansion
- persisted expansion state
- `NodePresenter` resolvers
- toolbar shell
- stable row context and partial locals

Host apps own product-specific rendering:

- table cells
- links and actions
- authorization
- dialogs and forms
- domain-specific labels and formatting

## Example presenter

```ruby
presenter = TreeView::NodePresenter.define do
  label { |item| item.title }
  href { |item| item.file? ? Rails.application.routes.url_helpers.document_path(item) : nil }
  tooltip { |item| item.summary }
  row_data { |item| { node_type: item.node_type } }
  badge { |item| item.status_label }
  icon { |item| item.node_type }
  actions { |item| item.file? ? [:download] : [] }
end
```

Pass it to `RenderState`:

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  node_presenter: presenter
)
```

When TreeView renders `row_partial`, the partial receives `item`, `tree`, `render_state`, `row_context`, and `node_presenter`. `row_actions_partial` receives the same locals.

## Example row partial

```erb
<td>
  <% label = node_presenter&.label_for(item) || item.to_s %>
  <% href = node_presenter&.href_for(item) %>

  <% if href %>
    <%= link_to label, href, title: node_presenter&.tooltip_for(item) %>
  <% else %>
    <%= label %>
  <% end %>

  <% if (badge = node_presenter&.badge_for(item)) %>
    <span class="badge"><%= badge %></span>
  <% end %>
</td>

<td>
  <%= item.updated_at.to_fs(:short) %>
</td>

<td>
  <% if node_presenter&.actions_for(item)&.include?(:download) && policy(item).download? %>
    <%= link_to "Download", download_document_path(item) %>
  <% end %>
</td>
```

This keeps the reusable resolver logic in `NodePresenter` while leaving action details and authorization in the host app.

## When to promote a pattern into TreeView

Consider moving a pattern from cookbook to TreeView only when it is:

- tree-specific rather than product-specific
- useful across multiple host apps
- expressible as a thin resolver or helper
- not coupled to authorization, forms, modals, or domain workflows

Until those conditions are met, prefer row partials, helpers, components, or ViewComponent in the host app.