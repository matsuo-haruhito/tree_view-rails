# PathTreeBuilder

`TreeView::PathTreeBuilder` turns records with path-like values into a renderable tree made of generated folder nodes and record nodes.

Use it when the host app has flat records such as documents, attachments, or generated artifacts that expose paths like `guides/setup/install.md`, but does not already have folder records in the database.

## Basic usage

```ruby
builder = TreeView::PathTreeBuilder.new(
  records: documents,
  path_resolver: ->(document) { document.source_relative_path },
  label_resolver: ->(document) { document.title },
  id_resolver: ->(document) { "document:#{document.id}" },
  sort: { folders_first: true }
)

render_state = TreeView::RenderState.new(
  tree: builder.tree,
  root_items: builder.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

The builder creates two public node shapes:

| Node | Fields | Description |
|---|---|---|
| `TreeView::PathTreeBuilder::FolderNode` | `key`, `parent_key`, `label`, `path`, `node_type` | Generated intermediate folders. |
| `TreeView::PathTreeBuilder::RecordNode` | `key`, `parent_key`, `label`, `path`, `record`, `node_type` | Leaf nodes wrapping host-app records. |

`RecordNode#record` keeps the original object so the row partial can render application-specific columns, links, status, or actions.

## Path inputs

`path_resolver` must be callable. It may return either a slash-separated string or an array of segments.

```ruby
path_resolver: ->(document) { document.source_relative_path }
path_resolver: ->(document) { [document.category_name, document.title] }
```

String paths are split with `separator`, which defaults to `/`.

```ruby
TreeView::PathTreeBuilder.new(
  records: attachments,
  path_resolver: ->(attachment) { attachment.tree_path },
  separator: "::"
)
```

Blank segments are ignored.

## Keys and labels

By default, folder keys are generated from folder paths with the `folder:` prefix. Record keys use `record:<id>` when the record responds to `id`, otherwise `record:<object_id>`.

Use `id_resolver` when records need stable or typed keys.

```ruby
id_resolver: ->(document) { TreeView.node_key(:document, document.id) }
```

Record labels are resolved in this order:

1. `label_resolver.call(record)` when provided
2. `record.name` when the record responds to `name`
3. the last path segment
4. `record.to_s`

## Sorting

Pass `sort: { folders_first: true }` to keep generated folders before records at each level.

For custom ordering, pass `sorter:`. It receives the same shape as `TreeView::Tree` sorters: `->(items, tree) { ... }`.

## Responsibility boundary

`PathTreeBuilder` only generates generic folder and record nodes from path-like values. Host apps still own queries, permissions, labels, links, file downloads, status badges, and row-specific actions.
