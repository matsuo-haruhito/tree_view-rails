# Host app extension points

このページでは、host Rails app が TreeView を拡張・統合するための主なhookを整理します。

## 概要

TreeViewは、業務固有の表示や挙動をgem内に持ち込まず、host app側のbuilderやpartialで拡張できるようにしています。

主なextension point:

- `row_partial`
- `row_class_builder`
- `row_data_builder`
- `badge_builder`
- `icon_builder`
- `depth_label_builder`
- `row_status_builder`
- `row_event_payload_builder`
- selection builders
- lazy loading path builders
- Turbo path builders

## row_partial

業務固有のcolumnsはhost app partialで描画します。

```ruby
row_partial: "documents/tree_columns"
```

```erb
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

## row class / data builders

```ruby
row_class_builder: ->(document) {
  ["document-row", ("is-current" if document == current_document)]
},
row_data_builder: ->(document) {
  { document_id: document.id }
}
```

## visual builders

```ruby
badge_builder: ->(document) { document.status },
icon_builder: ->(document) { document.folder? ? "folder" : "file" },
depth_label_builder: ->(_document, context) { "Level #{context.depth}" }
```

## behavior builders

```ruby
row_event_payload_builder: ->(document) {
  { id: document.id, key: tree.node_key_for(document) }
}
```

```ruby
selection: {
  enabled: true,
  payload_builder: ->(document) { { id: document.id, name: document.name } }
}
```

## path builders

Turboやlazy loadingのURLはhost appが作ります。

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
},
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| extension hook definitions | yes | no |
| builder invocation | yes | provides builders |
| business UI | no | yes |
| routes and controllers | no | yes |
| authorization | no | yes |
| CSS/design system | hooks only | yes |
