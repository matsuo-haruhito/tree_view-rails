# Cookbook

このページでは、TreeViewの既存APIを組み合わせた代表的な使い方をまとめます。

## 概要

cookbook は、個別APIの詳細仕様ではなく、host appでよく使う構成例を示すためのドキュメントです。

編集寄りの tree/table 画面については [Form と編集行](form-editing.md) を参照してください。bulk edit form、inline editing layout、Form Object、行単位の編集 action、validation error、TreeView と host app の責務境界を扱います。

より細かいAPI仕様は以下を参照してください。

- [API概要](api-overview.md)
- [使い方](usage.md)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)

## 行customization quick guide

追加したいUIに合わせて、最小のTreeView extension pointを使います。

| やりたいこと | 推奨hook | host appの責務 |
|---|---|---|
| 業務データ列 | `row_partial` | 表示field、format、link、permission |
| Edit、Show、Delete、Archive、独自action button | `row_actions_partial` | route、controller action、authorization、confirm文言 |
| input、select、inline編集label | `row_partial` または `row_actions_partial` | Form Object、validation、dirty state、保存 |
| level label | `depth_label_builder` | label文言とlocalization |
| badge、status pill、marker風label | `badge_builder` | status名、class、product semantics |
| legacy / direct toggle-cell marker text | toggle cellを直接描画する場合の `marker_builder` | marker名とclass |
| folder/file iconやtype label | `badge_builder`、`icon_builder`、または `row_partial` 内のcell | icon set、label、accessibility文言 |
| current row highlight、archived / disabled styling | `row_class_builder`、`row_data_builder`、Row status docs | 状態判定ruleとbehavior |

TreeViewは再利用可能なtree構造、row rendering slot、toggle / selection hook、browser integration markerを提供します。CRUD、保存、validation、authorization、product固有action、host app固有workflowはhost app側で実装します。

## row_partialで表示列を追加する

主要なrow contentは設定した `row_partial` に置きます。name、owner、updated time、size、typeなどの業務列に向いています。

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
<td><%= l(item.updated_at, format: :short) %></td>
```

route判断、authorization check、product固有formatはhost app partialに置きます。

## row_actions_partialで行action linkを追加する

Edit、Show、Delete、Archive、Duplicate、application固有actionなどの行単位action link / buttonは `row_actions_partial` に置きます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  row_actions_partial: "documents/tree_actions",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td class="document-actions">
  <%= link_to "Show", document_path(item) %>
  <%= link_to "Edit", edit_document_path(item) %>
  <%= button_to "Delete", document_path(item), method: :delete, data: { turbo_confirm: "Delete this document?" } %>
</td>
```

このpartialでは `item`、`tree`、`render_state` を使えます。TreeViewはslotだけを提供し、route、authorization、confirm文言、controller behavior、保存はhost appが担当します。

## 行内にtext inputやselectを置く

native controlはrow contentにもrow actionsにも置けます。TreeViewは input、select、textarea、button、link、`contenteditable` label をhost app側controlとして扱い、そこからTreeView keyboard navigationやtransfer drag behaviorを開始しません。

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
</td>
<td>
  <%= select_tag "documents[#{item.id}][status]",
        options_for_select(Document.statuses.keys, item.status) %>
</td>
```

native controlではないcustom widgetでは、widgetまたは祖先要素に `data-tree-view-interactive="true"` を付けます。

validation、dirty-state handling、form submission、conflict handling、保存はhost app側の責務です。

## depth label、badge、marker、iconをcustomizeする

toggle cellにlevel labelを表示したい場合は `depth_label_builder` を使います。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(_document, depth) { "Level #{depth + 1}" }
)
```

file type、workflow state、注意喚起markerなどの短いlabelは `badge_builder` に向いています。

```ruby
badge_builder = ->(document) {
  if document.archived?
    { text: "Archived", class: "is-muted", title: "This document is archived" }
  elsif document.requires_review?
    { text: "Review", class: "is-warning" }
  end
}
```

`badge_builder` はtext、または `text` / `label`、任意の `class`、`title`、`data` を持つHash-like objectを返せます。toggle cellをlegacy / direct renderingする場合は `marker_builder` も同じmarker風labelとして使えます。新しい `RenderState` codeでは `badge_builder` を優先します。

folder/file type labelを小さく表示する場合は badge / icon builder を使えます。より複雑なicon markupが必要なら、HTMLとaccessibility文言をhost appが管理できるよう `row_partial` に置きます。

```ruby
icon_builder = ->(document) {
  document.folder? ? { text: "Folder", class: "is-folder" } : { text: "File", class: "is-file" }
}
```

## current / archived / disabled / status rowを強調する

`<tr>` 全体の見た目に関わる状態は `row_class_builder` を使い、toggle付近に短いstatus textを出したい場合は `badge_builder` を組み合わせます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    [
      "document-row",
      ("is-current" if document.id == params[:id].to_i),
      ("is-archived" if document.archived?),
      ("is-disabled" unless document.editable?)
    ]
  },
  badge_builder: ->(document) {
    next { text: "Archived", class: "is-muted" } if document.archived?
    next { text: "Locked", class: "is-locked" } unless document.editable?
  }
)
```

host app JavaScriptが安定したmetadataを必要とする場合は `row_data_builder` を使います。TreeView levelのinteractionとしてreadonly / disabledを表したい場合は [Row status](row-status.md) も参照してください。authorization decisionや業務ruleは引き続きhost app側で扱います。

## 名前順で安定ソートする

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by { |node| [node.name.to_s, node.id] }
}

tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  sorter: sorter
)
```

最後に `id` のような安定化keyを入れると、同名nodeの表示順がぶれにくくなります。

## display_orderを優先してソートする

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by do |node|
    [
      node.display_order || Float::INFINITY,
      node.name.to_s,
      node.id
    ]
  end
}
```

`nil` は `Float::INFINITY` に寄せると、未設定項目を末尾にできます。

## 検索結果まで初期展開する

```ruby
matched_documents = Document.search(params[:q]).to_a
expanded_keys = tree.expanded_keys_for_paths(matched_documents)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed,
  expanded_keys: expanded_keys
)
```

検索結果の親階層を補完して表示したい場合は `path_tree_for` も使えます。

```ruby
path_tree = tree.path_tree_for(matched_documents)
```

## leafだけを選択可能にする

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    visibility: :leaves,
    checkbox_name: "selected_documents[]"
  }
)
```

## archived nodeを選択不可にする

```ruby
selection: {
  enabled: true,
  disabled_builder: ->(document) { document.archived? },
  disabled_reason_builder: ->(document) {
    document.archived? ? "アーカイブ済みのため選択できません" : nil
  }
}
```

## 大きなtreeの初期HTMLを減らす

まず `max_initial_depth` や `max_render_depth` で初期描画量を制限します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_initial_depth: 1
)
```

表示対象行が多い場合は windowed rendering を使います。

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

子nodeを必要な分だけ読み込みたい場合は lazy loading を使います。

## 行に状態classを付ける

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    ["document-row", ("is-archived" if document.archived?)]
  }
)
```

行全体のdisabled / readonly状態を表す場合は [Row status](row-status.md) も参照してください。

## node_key衝突を避ける

異種nodeを同じtreeで扱う場合は、class名などを含めます。

```ruby
node_key_resolver = ->(node) {
  TreeView.node_key(node.class.name, node.id)
}
```

詳細は [Node keys](node-keys.md) を参照してください。
