# Breadcrumb

This page explains the helper for rendering a TreeView node path as breadcrumbs.

## Overview

The breadcrumb helper uses a records-mode `TreeView::Tree` to look up the path from root to the target item and render it as breadcrumbs.

TreeView is responsible for:

- looking up the path from root to item with `tree.path_for(item)`
- rendering HTML through `tree_view_breadcrumb(tree, item, ...)`
- customization through label builders, path builders, classes, separators, and additive HTML attributes
- raising clear errors when used with unsupported modes

The host app remains responsible for routes, authorization, choosing the current item, deciding where breadcrumbs appear in the layout, and implementing analytics or Turbo behavior attached to custom attributes.

## Minimal example

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name }
) %>
```

`label_builder:` is required because TreeView does not assume how records should be displayed. When `path_builder` is omitted, TreeView renders plain labels.

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
  label_builder: ->(item) { item.name },
  nav_class: "breadcrumb-nav",
  list_class: "breadcrumb",
  item_class: "breadcrumb-item",
  link_class: "breadcrumb-link",
  current_class: "breadcrumb-current",
  separator: "/",
  separator_class: "breadcrumb-separator",
  aria_label: "Node path"
) %>
```

## HTML attributes

Use `html:` for the `<nav>` element and item-aware `link_html:` / `current_html:` hooks for lightweight host-app attributes such as Turbo frame targets, analytics metadata, or system spec hooks.

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  path_builder: ->(item) { document_path(item) },
  html: { data: { controller: "breadcrumb-analytics" } },
  link_html: ->(item) { { data: { document_id: item.id }, rel: "up" } },
  current_html: ->(item) { { data: { current_document_id: item.id } } }
) %>
```

TreeView merges these attributes with its built-in classes and accessibility attributes. `aria-label` on the `<nav>` still comes from `aria_label:`, and the current item keeps `aria-current="page"`.

For markup changes that need custom wrappers, conditional authorization copy, or route-specific behavior beyond attributes, render from `tree.path_for(item)` directly in the host app instead of stretching the bundled helper.

## Builders

| option | meaning |
|---|---|
| `label_builder:` | Required callable that returns the display label for each item. |
| `path_builder:` | Callable that returns the URL/path for each item. Plain labels are rendered when omitted. |
| `html:` | Additional attributes for the `<nav>` element. |
| `list_html:` | Additional attributes for the `<ol>` element. |
| `item_html:` | Additional attributes for each `<li>` element. A callable receives the item. |
| `link_html:` | Additional attributes for link elements. A callable receives the item. |
| `current_html:` | Additional attributes for the current label element. A callable receives the item. |
| `separator_html:` | Additional attributes for separator elements. A callable receives the previous item. |
| `nav_class:` | Class for the breadcrumb `<nav>` container. |
| `list_class:` | Class for the root list element. |
| `item_class:` | Class for each item element. |
| `link_class:` | Class for link elements. |
| `current_class:` | Class for the current node label. |
| `separator_class:` | Class for separator elements. |
| `separator:` | Separator between items. |
| `aria_label:` | Accessible label for the breadcrumb `<nav>` element. |

The option names in this table are also listed in `config/public_api_manifest.yml` under `helper_option_keys.tree_view_breadcrumb`. That manifest-backed list is a compatibility contract for the existing helper option surface; it does not add markup, route, or authorization behavior.

The default class names rendered when those class options are omitted are bundled styling references. They are not listed in the manifest-backed compatibility surface, and host apps that need stable public styling hooks should pass explicit class options instead of depending on the bundled defaults.

## Supported mode

The breadcrumb helper expects a records-mode tree.

Resolver mode and adapter mode may not have a unique parent path. For unsupported modes, TreeView raises through the tree path helper so the failure is explicit.

## Visual reference

For a static comparison of breadcrumb-path context beside the tree's own current-row cue, see [breadcrumb-paths.html](../mockups/breadcrumb-paths.html).

Use that mockup as a visual companion to this helper boundary: it highlights path lookup context, current-item rendering, and the host-app-owned route or authorization decisions without defining routes or Turbo navigation.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| path lookup in records mode | yes | provides tree/item |
| breadcrumb HTML helper | yes | calls helper |
| label customization | builder hook | provides builder |
| URL/path customization | builder hook | provides routes |
| lightweight HTML/data attributes | merge hooks | provides attributes and behavior |
| authorization | no | yes |
| current item selection | no | yes |
| layout placement | no | yes |
