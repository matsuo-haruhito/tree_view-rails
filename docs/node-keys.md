# Node keys

`TreeView.node_key(type, value)` builds a simple namespaced key for mixed node trees or screens that render multiple TreeViews.

## Basic usage

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  node_key_resolver: ->(document) { TreeView.node_key("document", document.id) }
)
```

This returns strings like `document:123`.

## Why use it

Using plain database ids can collide when a tree contains multiple model types.
A namespaced key keeps the id readable while reducing accidental collisions.

## Boundary

This helper only builds a stable string key.
It does not change database ids, encrypt values, or validate host app specific identifiers.
