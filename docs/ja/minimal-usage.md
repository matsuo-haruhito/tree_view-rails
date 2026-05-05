# host appでの最小利用例

このページでは、Rails host app でrecordsからツリーを描画するための最小構成を示します。

## 目的

最小構成は以下の3つです。

1. controllerで `TreeView::Tree` を作る。
2. `TreeView::UiConfigBuilder` でstatic用の `TreeView::UiConfig` を作る。
3. viewで `TreeView::RenderState` から行を描画する。

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

`parent_id_method` には親IDを返すmethod名を指定します。この例では `Document#parent_document_id` を使います。

`node_prefix` はDOM IDなどに使うprefixです。同じ画面に複数TreeViewを置く場合は、衝突しない値にしてください。

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

`tree_view_rows(@render_state)` は、root rows からツリー行を描画します。

## Row partial

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
```

`row_partial` には、TreeView標準行の中に差し込む列部分を指定します。

このpartialでは `item` を使えます。

## selection付きの最小例

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

`visibility: :leaves` はleaf nodeだけにcheckboxを表示します。

詳しくは [Selection](../selection.md) を参照してください。

## 次に読むもの

- [導入手順](installation.md)
- [使い方](../usage.md)
- [API概要](api-overview.md)
- [API仕様](../api.md)
- [Selection](../selection.md)
