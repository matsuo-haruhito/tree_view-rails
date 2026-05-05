# Node keys

This page explains how `node_key` values identify nodes in TreeView.

## Overview

`node_key` is the key TreeView uses to identify a node.

It is used by:

- `expanded_keys`
- `collapsed_keys`
- `selected_keys`
- DOM ID generation
- persisted state
- row event payloads
- diagnostics

In simple records mode, the record ID is often enough. When multiple trees appear on the same screen or heterogeneous nodes are used in one tree, design keys carefully to avoid collisions.

## Records mode

Records mode uses the value returned by `id_method` by default.

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)

tree.node_key_for(document)
```

You can customize `id_method:`.

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  id_method: :uuid
)
```

## Resolver / adapter mode

In resolver mode or adapter mode, prefer an explicit `node_key_resolver`.

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)
```

For heterogeneous nodes, include a class name or namespace to avoid collisions.

## TreeView.node_key helper

Use `TreeView.node_key` to build a stable key from multiple values.

```ruby
TreeView.node_key("document", document.id)
TreeView.node_key(document.class.name, document.id)
```

Whitespace is normalized, making the result easier to use in DOM IDs and related hooks.

## Avoiding collisions

Bad example:

```ruby
node_key_resolver: ->(node) { node.id }
```

This can collide when `Document#id == 1` and `Folder#id == 1` appear in the same tree.

Better example:

```ruby
node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
```

## Uniqueness validation

Enable uniqueness validation to catch duplicate node keys early.

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  validate_node_keys: true
)
```

Duplicate keys raise a clear error.

## Design policy

`node_key` is not always the same as the host app's domain ID.

Design it as the key for the unit TreeView should treat as the same node.

| Situation | Recommendation |
|---|---|
| Single-model records mode | Record ID is often enough. |
| Multiple models in one tree | Class name + ID. |
| Same record rendered in multiple trees | Tree prefix + class name + ID. |
| Persisted state | Use long-term stable keys. |
| Avoiding DOM ID collisions | Include a namespace. |
