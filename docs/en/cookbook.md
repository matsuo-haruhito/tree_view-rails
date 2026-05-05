# Cookbook

This page collects common ways to combine existing TreeView APIs in host apps.

## Overview

The cookbook is not a detailed API reference. It shows practical patterns that host apps commonly need.

For API details, see:

- [API overview](api-overview.md)
- [Usage](usage.md)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)

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
