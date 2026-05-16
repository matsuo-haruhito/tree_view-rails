# Turbo frame option

`UiConfigBuilder#build_turbo` accepts `turbo_frame:` for host apps that want TreeView toggle links to target a specific Turbo Frame without adding custom JavaScript.

## Basic usage

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth: depth, scope: scope) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth: depth, scope: scope) },
  toggle_all_path_builder: ->(state) { documents_path(state: state) },
  turbo_frame: "documents_tree"
)
```

TreeView adds the frame target to Turbo toggle links:

```html
<a data-turbo-stream="true" data-turbo-frame="documents_tree" ...>
```

## Scope

This option only adds `data-turbo-frame` to TreeView Turbo toggle links. It does not create frames, controller actions, authorization, or Turbo Stream responses.

Host apps remain responsible for:

- rendering the target `<turbo-frame>`
- implementing expand/collapse endpoints
- returning Turbo Stream or frame-compatible responses
- authorization and business rules
- persistence of expanded keys

## Why this belongs in TreeView

Targeting a Turbo Frame is a common Hotwire integration point for tree UIs, and it can be represented as a thin configuration value. It helps Rails apps avoid custom JavaScript while keeping response behavior in the host app.
