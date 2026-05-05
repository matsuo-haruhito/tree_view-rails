# Minimal host app usage / host appでの最小利用例

This page shows the smallest practical setup for rendering a tree from records in a Rails host app.

このページでは、Rails host app でrecordsからツリーを描画するための最小構成を示します。

## Goal / 目的

The minimal setup has three parts:

最小構成は以下の3つです。

1. Build a `TreeView::Tree` in the controller.
2. Build a static `TreeView::UiConfig` with `TreeView::UiConfigBuilder`.
3. Render rows from `TreeView::RenderState` in the view.

日本語では、controllerで `TreeView::Tree` を作り、`TreeView::UiConfigBuilder` でstatic用のUI設定を作り、viewで `TreeView::RenderState` から行を描画します。

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

`records` には表示対象のActive Record objectsを渡します。

Pass the Active Record objects you want to render as `records`.

`parent_id_method` には親IDを返すmethod名を指定します。この例では `Document#parent_document_id` を使います。

Use `parent_id_method` to tell TreeView which method returns the parent ID. This example uses `Document#parent_document_id`.

`node_prefix` はDOM IDなどに使うprefixです。同じ画面に複数TreeViewを置く場合は、衝突しない値にしてください。

`node_prefix` is used for DOM IDs and related helpers. Use a distinct prefix when rendering multiple TreeViews on the same page.

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

`tree_view_rows(@render_state)` は、root rows からツリー行を描画します。

`tree_view_rows(@render_state)` renders tree rows starting from the root rows.

## Row partial

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
```

`row_partial` には、TreeView標準行の中に差し込む列部分を指定します。

`row_partial` points to the host app partial that renders the custom columns inside the TreeView row.

このpartialでは `item` を使えます。

The partial receives `item`.

## With selection / selection付きの最小例

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

`selection.enabled` を `true` にするとcheckbox selectionを有効化できます。

Set `selection.enabled` to `true` to enable checkbox selection.

`visibility: :leaves` はleaf nodeだけにcheckboxを表示します。

`visibility: :leaves` renders checkboxes only for leaf nodes.

詳しくは [Selection](selection.md) を参照してください。

See [Selection](selection.md) for details.

## Next steps / 次に読むもの

- [Installation / 導入手順](installation.md)
- [Usage / 使い方](usage.md)
- [API reference / API仕様](api.md)
- [Selection](selection.md)
