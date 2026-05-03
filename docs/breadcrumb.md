# Breadcrumb helper

`tree_view_breadcrumb` renders a lightweight breadcrumb for a node path.

It is intentionally thin: TreeView resolves the node path, while the host app controls labels and URLs through builders.

## Basic usage

```erb
<%= tree_view_breadcrumb(
  @tree,
  @current_document,
  label_builder: ->(document) { document.name },
  path_builder: ->(document) { document_path(document) }
) %>
```

The helper uses `tree.path_for(item)`, so it is supported in records mode only.
Resolver mode and adapter mode do not provide parent lookup and therefore raise the same records-mode error as `path_for`.

## Output structure

The helper renders:

- `nav.tree-view-breadcrumb`
- `ol.tree-view-breadcrumb__list`
- `li.tree-view-breadcrumb__item`
- `a.tree-view-breadcrumb__link` for non-current nodes when `path_builder` is given
- `span.tree-view-breadcrumb__current` for the current node

The current node receives `aria-current="page"`.

## Plain labels

Omit `path_builder` when every path item should be rendered as text only.

```erb
<%= tree_view_breadcrumb(
  @tree,
  @current_document,
  label_builder: ->(document) { document.name }
) %>
```

## Custom classes

```erb
<%= tree_view_breadcrumb(
  @tree,
  @current_document,
  label_builder: ->(document) { document.name },
  path_builder: ->(document) { document_path(document) },
  separator: "/",
  nav_class: "breadcrumb",
  list_class: "breadcrumb-list",
  item_class: "breadcrumb-item",
  link_class: "breadcrumb-link",
  current_class: "breadcrumb-current",
  separator_class: "breadcrumb-separator",
  aria_label: "Document path"
) %>
```

## Responsibility boundary

TreeView does not decide business labels, URLs, authorization, or whether a path item should be clickable.
Keep those decisions in the host app and pass them through `label_builder` and `path_builder`.
