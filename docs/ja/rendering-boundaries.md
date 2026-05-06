# Rendering boundaries

このページでは、TreeView gem とhost Rails appの描画責務の境界を説明します。

## 概要

TreeViewは、tree rowを描画するためのRails helper、partial、context、builder hookを提供します。

一方で、業務固有の列、button、form、認可、Turbo response、controller actionはhost app側で実装します。

## TreeViewが担当するもの

- tree構造のtraversal
- row wrapperの描画
- depth、branch、toggle、selectionなどの共通UI primitive
- `row_partial` への `item` / context の受け渡し
- DOM ID / path builder hook
- row class/data builderの評価

## Host appが担当するもの

- table全体やpage layout
- row partialの中身
- 業務固有の列やaction button
- controller action
- Turbo Stream response
- authorization
- query / filtering / pagination
- CSS themeやdesign systemとの統合

## row_partialの境界

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
<td><%= link_to "Edit", edit_document_path(item) %></td>
```

TreeViewはrowの外側と共通UIを描画し、host app partialが業務固有のcolumnsを描画します。

## Turboの境界

TreeViewはpath builderを呼んでURLを作ります。

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

そのURLのcontroller action、query、Turbo Stream responseはhost app側の責務です。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| tree row traversal | yes | no |
| common tree UI cells | yes | no |
| business columns | no | yes |
| path generation hook | calls builder | provides builder |
| Turbo response | no | yes |
| authorization | no | yes |
| page layout | no | yes |
| design system integration | hooks only | yes |
