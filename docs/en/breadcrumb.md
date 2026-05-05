# Breadcrumb

This page explains the helper for rendering a TreeView node path as breadcrumbs.

## Overview

The breadcrumb helper uses a records-mode `TreeView::Tree` to look up the path from root to the target item and render it as breadcrumbs.

TreeView is responsible for:

- looking up the path from root to item with `tree.path_for(item)`
- rendering HTML through `tree_view_breadcrumb(tree, item, ...)`
- customization through label builders, path builders, classes, and separators
- raising clear errors when used with unsupported modes

The host app remains responsible for routes, authorization, choosing the current item, and deciding where breadcrumbs appear in the layout.

## Minimal example

```erb
<%= tree_view_breadcrumb(@tree, @document) %>
```

When `path_builder` is omitted, TreeView renders plain labels.

## Breadcrumbs with links

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  path_builder: ->(item) { document_path(item) }
) %>
```

The current item is rendered as a current label instead of a link.

## Classes and separator

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  list_class: "breadcrumb",
  item_class: "breadcrumb-item",
  link_class: "breadcrumb-link",
  current_class: "breadcrumb-current",
  separator: "/"
) %>
```

## Builders

| option | meaning |
|---|---|
| `label_builder:` | Callable that returns the display label for each item. |
| `path_builder:` | Callable that returns the URL/path for each item. Plain labels are rendered when omitted. |
| `list_class:` | Class for the root list element. |
| `item_class:` | Class for each item element. |
| `link_class:` | Class for link elements. |
| `current_class:` | Class for the current node label. |
| `separator:` | Separator between items. |

## Supported mode

The breadcrumb helper expects a records-mode tree.

Resolver mode and adapter mode may not have a unique parent path. For unsupported modes, TreeView raises through the tree path helper so the failure is explicit.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| path lookup in records mode | yes | provides tree/item |
| breadcrumb HTML helper | yes | calls helper |
| label customization | builder hook | provides builder |
| URL/path customization | builder hook | provides routes |
| authorization | no | yes |
| current item selection | no | yes |
| layout placement | no | yes |
