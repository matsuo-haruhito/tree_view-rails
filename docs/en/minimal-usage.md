# Minimal host app usage

This page shows the smallest practical setup for rendering a tree from records in a Rails host app.

## Goal

The minimal setup has three parts:

1. Build a `TreeView::Tree` in the controller.
2. Build a static `TreeView::UiConfig` with `TreeView::UiConfigBuilder`.
3. Render rows from `TreeView::RenderState` in the view.

## Controller

```ruby
class DocumentsController < ApplicationController
  def index
    documents = Document.order(:name).to_a

    tree = TreeView::Tree.new(
      records: documents,
      parent_id_method: :parent_document_id
    )

    tree_ui = TreeView::UiConfigBuilder.new(
      context: view_context,
      node_prefix: "document"
    ).build_static

    @render_state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "documents/tree_columns",
      ui_config: tree_ui
    )
  end
end
```

Pass the Active Record objects you want to render as `records`.

Use `parent_id_method` to tell TreeView which method returns the parent ID. This example uses `Document#parent_document_id`.

`node_prefix` is used for DOM IDs and related helpers. Use a distinct prefix when rendering multiple TreeViews on the same page.

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

`tree_view_rows(@render_state)` renders tree rows starting from the root rows.

## Row partial

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
```

`row_partial` points to the host app partial that renders the custom columns inside the TreeView row.

The partial receives `item`.

## With selection

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    visibility: :leaves
  }
)
```

Set `selection.enabled` to `true` to enable checkbox selection.

`visibility: :leaves` renders checkboxes only for leaf nodes.

See [Selection](selection.md) for details.

## Visual check

After wiring the controller, view, and row partial above, use [minimal-usage-first-render.html](../mockups/minimal-usage-first-render.html) to inspect the first visible output from this minimal setup.

Use [default-tree.html](../mockups/default-tree.html) when you want the richer baseline with shared CSS, selection, badges, row actions, and expanded or collapsed states. The minimal first-render mockup stays close to this page's controller/view/row-partial example and does not add host-app CRUD, routes, seed data, or visual redesign requirements.

## Next steps

- [Installation](installation.md)
- [Usage](usage.md)
- [API overview](api-overview.md)
- [API reference](api.md)
- [Selection](selection.md)