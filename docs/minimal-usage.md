# Minimal host app usage

This page shows the smallest practical setup for rendering a tree from records in a Rails host app.

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

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

## Row partial

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
```

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
