# Host app extension points

このページでは、host Rails app が TreeView を拡張・統合するための主なhookを整理します。

## 概要

TreeViewは、業務固有の表示や挙動をgem内に持ち込まず、host app側のbuilderやpartialで拡張できるようにしています。

主なextension point:

- `row_partial`
- `row_class_builder`
- `row_data_builder`
- `badge_builder`
- `depth_label_builder`
- `row_status_builder`
- transfer payload builders
- selection builders
- lazy loading path builders
- Turbo path builders

`icon_builder` のcompatibility statusを含む公開名の判断は [Public Name Decisions](public-name-decisions.md) を参照してください。

## row_partial

業務固有のcolumnsはhost app partialで描画します。

```ruby
row_partial: "documents/tree_columns"
```

```erb
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

このpartialには、input、select、button、link、inline editable labelなど、host app側のcontrolも配置できます。TreeViewはnative interactive controlから発生したeventでは、keyboard navigationやtransfer drag startを実行しません。Custom controlでは、`data-tree-view-interactive="true"` または `data-tree-view-ignore-keyboard="true"`、`data-tree-view-ignore-row-click="true"`、`data-tree-view-ignore-drag="true"` のようなより狭いmarkerを付けます。

```erb
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
  <%= link_to "Edit", edit_document_path(item) %>
  <span data-tree-view-interactive="true">Custom picker</span>
</td>
```

詳しいrow control例は [使い方](usage.md#行内のinteractive-control) を参照してください。

## row class / data builders

```ruby
row_class_builder: ->(document) {
  ["document-row", ("is-current" if document == current_document)]
},
row_data_builder: ->(document) {
  { document_id: document.id }
}
```

## visual builders

row badge / marker 表示には `badge_builder` を使います。`icon_builder` はcompatibility aliasとして利用可能ですが、新しいcodeやexamplesでは `badge_builder` を推奨します。

```ruby
badge_builder: ->(document) { document.status },
depth_label_builder: ->(_document, context) { "Level #{context.depth}" }
```

## transfer payload builders

`row_event_payload_builder` はtransfer専用です。drag/drop transfer dataとしてserializeされるpayloadを返します。汎用row event hookではありません。

```ruby
row_event_payload_builder: ->(document) {
  { id: document.id, key: tree.node_key_for(document) }
}
```

## selection builders

```ruby
selection: {
  enabled: true,
  payload_builder: ->(document) { { id: document.id, name: document.name } }
}
```

`selection:` 設定は、`TreeView::RenderState` 内で row ごとの payload 生成、disabled-state 判定、selected keys、checkbox visibility を決める側の設定です。

host element に `tree-view-selection` controller を設定するときは、次の documented value attribute が stable な wiring surface に含まれます。

- `data-tree-view-selection-hidden-input-name-value`: 最寄り form への hidden input sync
- `data-tree-view-selection-max-count-value`: client-side の最大選択数制限
- `data-tree-view-selection-cascade-value`: 描画済み行どうしの cascade 挙動
- `data-tree-view-selection-indeterminate-value`: 親 checkbox の mixed-state 更新

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-hidden-input-name-value="selected_nodes[]"
  data-tree-view-selection-max-count-value="10"
  data-tree-view-selection-cascade-value="true"
  data-tree-view-selection-indeterminate-value="true">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

row ごとの意味づけは render-state 側の `selection:` option で行い、Stimulus controller が既に描画された checkbox をどう同期・制約するかは host-element value attribute 側で設定します。event や挙動の詳細は [Selection](selection.md) を参照してください。

## path builders

Turboやlazy loadingのURLはhost appが作ります。

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
},
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| extension hook definitions | yes | no |
| builder invocation | yes | provides builders |
| business UI | no | yes |
| interactive-control guards | yes | marks custom widgets when needed |
| routes and controllers | no | yes |
| authorization | no | yes |
| CSS/design system | hooks only | yes |
