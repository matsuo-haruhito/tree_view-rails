# Cookbook

This page collects common ways to combine existing TreeView APIs in host apps.

## Overview

The cookbook is not a detailed API reference. It shows practical patterns that host apps commonly need.

For editing-oriented tree/table screens, see [Forms and editing rows](form-editing.md). That page covers bulk edit forms, inline editing layouts, Form Objects, per-row edit actions, validation errors, and the responsibility boundary between TreeView and the host app.

For API details, see:

- [API overview](api-overview.md)
- [Usage](usage.md)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)

## Row customization quick guide

Use the smallest TreeView extension point that matches the UI you are adding.

| Need | Recommended hook | Host app owns |
|---|---|---|
| Business data columns | `row_partial` | Field choice, formatting, links, permissions |
| Edit, Show, Delete, Archive, or custom action buttons | `row_actions_partial` | Routes, controller actions, authorization, confirmation text |
| Inputs, selects, or inline editable labels | `row_partial` or `row_actions_partial` | Form object, validation, dirty state, persistence |
| Level labels | `depth_label_builder` | Label wording and localization |
| Badges, status pills, or marker-like labels | `badge_builder` | Status names, classes, and product semantics |
| Legacy/direct toggle-cell marker text | `marker_builder` when rendering toggle cells directly | Marker naming and classes |
| Folder/file icons or type labels | `badge_builder`, `icon_builder`, or a cell in `row_partial` | Icon set, labels, and accessibility copy |
| Current row highlighting or archived/disabled styling | `row_class_builder`, `row_data_builder`, and row-status docs | State rules and behavior |

TreeView owns reusable tree structure, row rendering slots, toggle/selection hooks, and browser integration markers. CRUD, persistence, validation, authorization, product-specific actions, and host-app business workflows stay in the host app.

## Add data display columns with row_partial

Put the main row content in the configured `row_partial`. This is the right place for business columns such as name, owner, updated time, size, or type.

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
<td><%= l(item.updated_at, format: :short) %></td>
```

Keep route decisions, authorization checks, and product-specific formatting in the host app partial.

## Add row action links with row_actions_partial

Use `row_actions_partial` for per-row action links and buttons such as Edit, Show, Delete, Archive, Duplicate, or application-specific actions.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  row_actions_partial: "documents/tree_actions",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td class="document-actions">
  <%= link_to "Show", document_path(item) %>
  <%= link_to "Edit", edit_document_path(item) %>
  <%= button_to "Delete", document_path(item), method: :delete, data: { turbo_confirm: "Delete this document?" } %>
</td>
```

The partial receives `item`, `tree`, and `render_state`. TreeView only supplies the slot; the host app owns routes, authorization, confirmation text, controller behavior, and persistence.

## Put text input and select controls inside a row

Native controls can live in row content or row actions. TreeView treats inputs, selects, textareas, buttons, links, and `contenteditable` labels as host-app controls and avoids starting tree keyboard navigation or transfer drag behavior from them.

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
</td>
<td>
  <%= select_tag "documents[#{item.id}][status]",
        options_for_select(Document.statuses.keys, item.status) %>
</td>
```

For custom widgets that are not native controls, add `data-tree-view-interactive="true"` to the widget or an ancestor.

Validation, dirty-state handling, form submission, conflict handling, and persistence remain host-app responsibilities.

## Customize depth labels, badges, markers, and icons

Use `depth_label_builder` when the toggle cell should show a level label.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(_document, depth) { "Level #{depth + 1}" }
)
```

Use `badge_builder` for compact labels in the toggle cell, such as file type, workflow state, or attention markers.

```ruby
badge_builder = ->(document) {
  if document.archived?
    { text: "Archived", class: "is-muted", title: "This document is archived" }
  elsif document.requires_review?
    { text: "Review", class: "is-warning" }
  end
}
```

`badge_builder` may return text or a hash-like object with `text` or `label`, optional `class`, `title`, and `data`. For legacy direct rendering of toggle cells, `marker_builder` follows the same marker-style idea; prefer `badge_builder` with `RenderState` in new code.

Use a badge or icon builder for compact folder/file type labels, or put richer icon markup in `row_partial` so the host app controls the HTML and accessibility copy.

```ruby
icon_builder = ->(document) {
  document.folder? ? { text: "Folder", class: "is-folder" } : { text: "File", class: "is-file" }
}
```

## Highlight current, archived, disabled, or status rows

Use `row_class_builder` when visual state belongs on the whole `<tr>` and `badge_builder` when compact status text should appear near the toggle.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    [
      "document-row",
      ("is-current" if document.id == params[:id].to_i),
      ("is-archived" if document.archived?),
      ("is-disabled" unless document.editable?)
    ]
  },
  badge_builder: ->(document) {
    next { text: "Archived", class: "is-muted" } if document.archived?
    next { text: "Locked", class: "is-locked" } unless document.editable?
  }
)
```

Use `row_data_builder` when host-app JavaScript needs stable metadata. If a row should be readonly or disabled for TreeView-level interaction, also see [Row status](row-status.md). Authorization decisions and business rules still belong in the host app.

## Stable name sorting

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by { |node| [node.name.to_s, node.id] }
}

tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  sorter: sorter
)
```

Add a stable key such as `id` at the end so nodes with the same name keep a predictable order.

## Prioritize display_order

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by do |node|
    [
      node.display_order || Float::INFINITY,
      node.name.to_s,
      node.id
    ]
  end
}
```

Use `Float::INFINITY` to place missing `display_order` values last.

## Expand to search results initially

```ruby
matched_documents = Document.search(params[:q]).to_a
expanded_keys = tree.expanded_keys_for_paths(matched_documents)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed,
  expanded_keys: expanded_keys
)
```

Use `path_tree_for` when search results should be shown with their ancestors.

```ruby
path_tree = tree.path_tree_for(matched_documents)
```

## Select only leaves

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    visibility: :leaves,
    checkbox_name: "selected_documents[]"
  }
)
```

## Disable archived nodes

```ruby
selection: {
  enabled: true,
  disabled_builder: ->(document) { document.archived? },
  disabled_reason_builder: ->(document) {
    document.archived? ? "Archived documents cannot be selected" : nil
  }
}
```

## Reduce initial HTML for large trees

Start by limiting initial rendering with `max_initial_depth` or `max_render_depth`.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_initial_depth: 1
)
```

Use windowed rendering when many visible rows remain.

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

Use lazy loading when children should be loaded only as needed.

## Add row state classes

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    ["document-row", ("is-archived" if document.archived?)]
  }
)
```

See [Row status](row-status.md) when the whole row should express disabled or readonly state.

## Avoid node_key collisions

For heterogeneous nodes in one tree, include the class name or another namespace.

```ruby
node_key_resolver = ->(node) {
  TreeView.node_key(node.class.name, node.id)
}
```

See [Node keys](node-keys.md) for details.
