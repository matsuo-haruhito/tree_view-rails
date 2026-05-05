# Cookbook

このページでは、TreeViewの既存APIを組み合わせた代表的な使い方をまとめます。

## 概要

cookbook は、個別APIの詳細仕様ではなく、host appでよく使う構成例を示すためのドキュメントです。

より細かいAPI仕様は以下を参照してください。

- [API概要](api-overview.md)
- [使い方](usage.md)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)

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
