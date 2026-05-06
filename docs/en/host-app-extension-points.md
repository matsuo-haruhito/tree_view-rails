# Host app extension points

This page summarizes the main hooks host Rails apps can use to extend and integrate TreeView.

## Overview

TreeView keeps business-specific display and behavior in the host app. The gem exposes builders and partial boundaries so host apps can extend the UI without changing TreeView internals.

Main extension points:

- `row_partial`
- `row_class_builder`
- `row_data_builder`
- `badge_builder`
- `depth_label_builder`
- `row_status_builder`
- transfer payload builders
- selection builders
- lazy loading path builders
- Turbo path builders

For focused naming decisions, including the compatibility status of `icon_builder`, see [Public Name Decisions](public-name-decisions.md).

## row_partial

Application-specific columns are rendered by the host app partial.

```ruby
row_partial: "documents/tree_columns"
```

```erb
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

## Row class / data builders

```ruby
row_class_builder: ->(document) {
  ["document-row", ("is-current" if document == current_document)]
},
row_data_builder: ->(document) {
  { document_id: document.id }
}
```

## Visual builders

Use `badge_builder` for row badge or marker display. `icon_builder` remains available as a compatibility alias, but new code and examples should prefer `badge_builder`.

```ruby
badge_builder: ->(document) { document.status },
depth_label_builder: ->(_document, context) { "Level #{context.depth}" }
```

## Transfer payload builders

`row_event_payload_builder` is transfer-specific. It returns the payload serialized for drag/drop transfer data; it is not a generic row event hook.

```ruby
row_event_payload_builder: ->(document) {
  { id: document.id, key: tree.node_key_for(document) }
}
```

## Selection builders

```ruby
selection: {
  enabled: true,
  payload_builder: ->(document) { { id: document.id, name: document.name } }
}
```

## Path builders

Turbo and lazy-loading URLs are provided by the host app.

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
},
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| extension hook definitions | yes | no |
| builder invocation | yes | provides builders |
| business UI | no | yes |
| routes and controllers | no | yes |
| authorization | no | yes |
| CSS/design system | hooks only | yes |
