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
    <%= link_to "Load more", children_document_path(@parent, cursor: @next_cursor, format: :turbo_stream) %>
  <% end %>
<% end %>
```

## Relationship to lazy loading

Children pagination is built by the host app on top of lazy loading.

- TreeView provides child URLs and row data hooks.
- The host app implements page-level queries, cursors, additional rendering, and next-page UI.

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
