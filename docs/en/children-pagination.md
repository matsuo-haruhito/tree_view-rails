# Children Pagination

This page explains how host apps can combine lazy loading with server-side pagination for nodes that have many children.

## Overview

Children pagination is a host-app design for loading large child sets in smaller pages.

TreeView does not provide a pagination algorithm.

TreeView is responsible for:

- generating child URLs through `load_children_path_builder`
- rendering lazy-loading row data attributes
- providing remote-state controller hooks
- defining the boundary where the host app can return child HTML or Turbo Streams

The host app remains responsible for cursors, offsets, limits, page tokens, next-page detection, queries, authorization, and Turbo Stream responses.

## URL design example

```ruby
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(
    item,
    depth: depth,
    scope: scope,
    cursor: params[:cursor],
    limit: 50,
    format: :turbo_stream
  )
}
```

In real host apps, it is often safer to build cursor and limit values explicitly in the controller rather than closing over `params` directly.

## Minimal cursor pattern

Prefer a stable ordering and request one extra record to detect whether another page exists.

```ruby
class DocumentsController < ApplicationController
  DEFAULT_CHILD_LIMIT = 50
  MAX_CHILD_LIMIT = 100

  def children
    @parent = Document.find(params[:id])
    authorize! @parent, :show?

    @limit = child_limit
    relation = @parent.children.visible_to(current_user).order(:name, :id)
    relation = apply_cursor(relation, params[:cursor]) if params[:cursor].present?

    page = relation.limit(@limit + 1).to_a
    @children = page.first(@limit)
    @next_cursor = page.size > @limit ? encode_cursor(@children.last) : nil

    @tree = TreeView::Tree.new(
      records: @children,
      parent_id_method: :parent_document_id,
      id_method: :id
    )

    @render_state = TreeView::RenderState.new(
      tree: @tree,
      root_items: @tree.root_items,
      row_partial: "documents/tree_columns",
      ui_config: tree_ui,
      lazy_loading: {
        enabled: true,
        loaded_keys: [TreeView.node_key("document", @parent.id)]
      }
    )
  end

  private

  def child_limit
    requested = params.fetch(:limit, DEFAULT_CHILD_LIMIT).to_i
    [[requested, 1].max, MAX_CHILD_LIMIT].min
  end

  def apply_cursor(relation, cursor)
    name, id = decode_cursor(cursor)
    relation.where("name > ? OR (name = ? AND id > ?)", name, name, id)
  end

  def encode_cursor(record)
    Base64.urlsafe_encode64([record.name, record.id].join("\0"))
  end

  def decode_cursor(cursor)
    Base64.urlsafe_decode64(cursor).split("\0", 2)
  rescue ArgumentError
    raise ActionController::BadRequest, "Invalid cursor"
  end
end
```

The exact cursor format is a host-app decision. The important parts are stable ordering, explicit limit clamping, and server-side cursor validation.

## Controller example

```ruby
class DocumentsController < ApplicationController
  def children
    parent = Document.find(params[:id])
    authorize! parent, :show?

    page = Document.where(parent_document_id: parent.id)
      .order(:name, :id)
      .limit(limit + 1)

    @children = page.first(limit)
    @next_cursor = page.size > limit ? @children.last.id : nil
  end

  private

  def limit
    [[params.fetch(:limit, 50).to_i, 1].max, 100].min
  end
end
```

## Turbo Stream example

The host app returns child rows and a "load more" UI.

```erb
<%= turbo_stream.append dom_id(@parent, :children) do %>
  <%= tree_view_rows(@render_state) %>
<% end %>

<% if @next_cursor %>
  <%= turbo_stream.replace dom_id(@parent, :children_more) do %>
    <%= link_to "Load more",
      children_document_path(@parent, cursor: @next_cursor, limit: @limit, format: :turbo_stream),
      data: { turbo_stream: true } %>
  <% end %>
<% else %>
  <%= turbo_stream.remove dom_id(@parent, :children_more) %>
<% end %>
```

Render the initial next-page placeholder where the host app wants it to appear:

```erb
<tr id="<%= dom_id(parent, :children_more) %>">
  <td colspan="6">
    <%= link_to "Load more",
      children_document_path(parent, cursor: next_cursor, limit: limit, format: :turbo_stream),
      data: { turbo_stream: true } %>
  </td>
</tr>
```

## Relationship to lazy loading

Children pagination is built by the host app on top of lazy loading.

- TreeView provides child URLs and row data hooks.
- The host app implements page-level queries, cursors, additional rendering, and next-page UI.

## Selection and drag/drop interactions

Pagination means some descendants are not present in the DOM yet. Define product behavior explicitly:

| Feature | Recommended host-app decision |
|---|---|
| Checkbox selection | Decide whether selection applies only to loaded rows or to the entire filtered child set. If it applies beyond loaded rows, submit a server-side selection intent rather than only checkbox values from the DOM. |
| Cascade selection | Treat unloaded descendants as unknown unless the server computes the cascade. Do not imply that a parent checkbox represents all children when only one page is loaded. |
| Drag/drop | Validate moves on the server. Invisible or unloaded siblings can affect allowed positions, ordering, and conflict checks. |
| Bulk actions | Use query-backed actions when the action should affect unloaded children. Use DOM-submitted checkbox values only for loaded-row actions. |
| Retry/error UI | Keep retry controls scoped to the parent/page that failed so another page can remain loaded. |

## Notes

- Always use stable ordering, for example `order(:name, :id)`.
- Put an upper bound on `limit`.
- Validate cursors or page tokens in the host app.
- When combining pagination with drop/reorder behavior, define how invisible nodes should be handled as part of the product behavior.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| child URL hook | yes | provides builder |
| lazy-loading row data | yes | consumes data |
| remote-state events | hooks only | dispatches events |
| cursor / offset / token | no | yes |
| query and ordering | no | yes |
| next-page detection | no | yes |
| Turbo Stream response | no | yes |
| authorization | no | yes |
| retry/error UI | hooks only | yes |
