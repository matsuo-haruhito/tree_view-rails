# Rendering boundaries

This page explains the rendering responsibility boundary between the TreeView gem and the Rails host app.

## Overview

TreeView provides Rails helpers, partials, contexts, and builder hooks for rendering tree rows.

The host app owns business-specific columns, buttons, forms, authorization, Turbo responses, and controller actions.

## TreeView responsibilities

- tree traversal
- row wrapper rendering
- common UI primitives such as depth, branch, toggle, and selection cells
- passing `item` and context into `row_partial`
- DOM ID and path builder hooks
- evaluating row class/data builders

## Host app responsibilities

- table wrapper and page layout
- contents of the row partial
- business-specific columns and action buttons
- controller actions
- Turbo Stream responses
- authorization
- queries, filtering, and pagination
- CSS theme or design system integration

## row_partial boundary

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
<td><%= link_to "Edit", edit_document_path(item) %></td>
```

TreeView renders the row wrapper and common UI. The host app partial renders application-specific columns.

## Turbo boundary

TreeView calls path builders to build URLs.

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

The controller action, query, and Turbo Stream response for that URL belong to the host app.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| tree row traversal | yes | no |
| common tree UI cells | yes | no |
| business columns | no | yes |
| path generation hook | calls builder | provides builder |
| Turbo response | no | yes |
| authorization | no | yes |
| page layout | no | yes |
| design system integration | hooks only | yes |
