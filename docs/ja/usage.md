# 使い方

このページでは、Rails host app でTreeViewの行を描画する基本的な流れを説明します。

より詳細な既存ガイドは、移行期間中は [root usage guide](../usage.md) も参照してください。

## 基本の流れ

1. records、resolver、adapter から `TreeView::Tree` を作る。
2. `TreeView::UiConfigBuilder` で `TreeView::UiConfig` を作る。
3. 画面単位の `TreeView::RenderState` を作る。
4. `tree_view_rows(@render_state)` で行を描画する。
5. host app固有の列は `row_partial` に実装する。

TreeView gem はツリーUIの基盤を提供します。CRUD、認可、保存、server-side query、Turbo Stream response、業務固有actionはhost app側で実装します。

## 通常Tree

親子関係を持つrecordsからtreeを作る場合は、`records:` と `parent_id_method:` を指定します。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)
```

並び順を変えたい場合は `sorter:` を渡します。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)
```

複数キーで安定した並び順にしたい場合は、`sort_by` の戻り値を配列にします。

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

## static表示

開閉URLを使わない静的なツリーとして表示する場合は `build_static` を使います。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_static
```

## Turbo Stream開閉

Turbo Streamで開閉したい場合は、`build` にpath builderを渡します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build(
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(state: state)
  }
)
```

path builderはURLを作るだけです。実際のcontroller action、Turbo Stream response、認可、server-side queryはhost app側の責務です。

## RenderState

画面単位の描画状態は `TreeView::RenderState` にまとめます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

`initial_state` は省略できます。省略した場合はglobal config、さらに未設定なら `:expanded` が使われます。

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

windowed renderingを使う場合は、`window:` を渡します。

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

## Row partial

host app固有の列は `row_partial` に実装します。

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

このpartialでは `item` を使えます。

## 行内のinteractive control

host appは `row_partial` や `row_actions_partial` の中に、input、select、textarea、button、link、`contenteditable` label を配置できます。TreeViewはこれらのnative interactive elementをhost app側のcontrolとして扱い、それらから発生したeventではTreeViewのkeyboard navigationやtransfer drag startを実行しません。

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
</td>
```

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td>
  <%= link_to "Edit", edit_document_path(item) %>
  <%= button_to "Archive", archive_document_path(item), method: :post %>
</td>
```

native controlではないcustom widgetでは、row内のwidgetまたはその祖先に `data-tree-view-interactive="true"` を付けます。

```erb
<td>
  <span data-tree-view-interactive="true" contenteditable="true"><%= item.name %></span>
</td>
```

特定のTreeView動作だけを無視したい場合は、より狭いmarkerを使えます。

- `data-tree-view-ignore-keyboard="true"` は、arrow key、space、enter によるTreeView keyboard navigationを抑止します。
- `data-tree-view-ignore-row-click="true"` は、host app側のrow click連携向けに予約されています。
- `data-tree-view-ignore-drag="true"` は、そのcontrolからTreeView transfer drag startが始まることを抑止します。

これらのmarkerはTreeView側の動作を無視するためのものです。validation、保存、認可、CRUD route、inline editing flowは引き続きhost app側で実装します。

## grouped option

描画範囲・初期展開・開閉範囲は、概念単位でまとめて指定できます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    max_depth: 2,
    expanded_keys: expanded_keys
  },
  render_scope: {
    max_depth: 3,
    max_leaf_distance: 2
  },
  toggle_scope: {
    max_depth_from_root: 2,
    max_leaf_distance: 1
  }
)
```

個別引数とgrouped optionを同時に指定した場合は、後方互換性のため個別引数を優先します。

## Selection

checkbox selectionを使う場合は `selection:` を指定します。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    visibility: :leaves
  }
)
```

checkboxの描画、payload生成、JavaScript controllerによる収集はTreeViewが担当します。削除・移動・関連付けなどの業務処理はhost app側で実装します。

詳しくは [Selection](../selection.md) を参照してください。

## Lazy loading

子nodeを必要なタイミングで読み込む場合は、`load_children_path_builder` と `RenderState#lazy_loading` を使います。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth:, scope:) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth:, scope:) },
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: loaded_keys
  }
)
```

fetch、Turbo request、retry、loading message、認可はhost app側で実装します。

## PathTree / ReverseTree

検索結果などから親階層を補完して表示する場合は `path_tree_for` を使います。

```ruby
path_tree = base_tree.path_tree_for(matched_documents)
```

子nodeから親方向に辿る表示をしたい場合は `reverse_tree_for` を使います。

```ruby
reverse_tree = base_tree.reverse_tree_for(matched_documents)
```

| API | 表示方向 | 用途 |
|---|---|---|
| `path_tree_for(items)` | root → parent → matched item | 通常の階層構造内で検索結果を確認する |
| `reverse_tree_for(items)` | matched item → parent → root | 子node一覧から親方向へ辿る |

## 次に読むもの

- [API概要](api-overview.md)
- [API仕様](../api.md)
- [Selection](../selection.md)
- [Lazy Loading](../lazy-loading.md)
- [Windowed Rendering](../windowed-rendering.md)
