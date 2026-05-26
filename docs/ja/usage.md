# 使い方

このページでは、Rails host app で TreeView の行を描画する基本的な流れを説明します。

language-specific docs 全体の入口と関連ガイドは [docs index](../README.md) を参照してください。

## 基本の流れ

1. records、resolver、adapter から `TreeView::Tree` を作る。
2. `TreeView::UiConfigBuilder` で `TreeView::UiConfig` を作る。
3. 画面単位の `TreeView::RenderState` を作る。
4. `tree_view_rows(@render_state)` で行を描画する。
5. host app 固有の列は `row_partial` に実装する。

TreeView gem はツリー UI の基盤を提供します。CRUD、認可、保存、server-side query、Turbo Stream response、業務固有 action は host app 側で実装します。

## toggle mode

開閉方式は tree instance ごとに選びます。1つの host app 内で画面ごとに使い分けたり、同じ page 内に異なる mode の tree を並べたりできます。

| Builder | Mode | 挙動 |
|---|---|---|
| `build_turbo` / `build` | `:turbo` | host app の Turbo Stream endpoint で開閉する。 |
| `build_static` | `:static` | 静的 snapshot として描画する。collapsed descendants は描画されず、browser 上では開けない。 |
| `build_client_side` | `:client` | 初期 HTML に descendants を残し、TreeView JavaScript で browser 内だけで表示/非表示を切り替える。 |

## static表示

開閉 URL を使わない静的なツリーとして表示する場合は `build_static` を使います。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_static
```

## Turbo Stream開閉

Turbo Stream で開閉したい場合は、`build_turbo` に path builder を渡します。`build` は後方互換のため `build_turbo` と同じ意味で残しています。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
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

path builder は URL を作るだけです。実際の controller action、Turbo Stream response、認可、server-side query は host app 側の責務です。

bundled HTML helper を使わず、host app 側で toolbar markup を組み立てたい場合は、まず documented された supported action set を取得してから、app-owned な link / button を描画します。

```erb
<% supported_actions = tree_view_toolbar_supported_actions %>

<% tree_view_toolbar_actions(@render_state, actions: supported_actions).each do |action| %>
  <% if action[:path] %>
    <%= link_to action[:label], action[:path], data: action[:data] %>
  <% else %>
    <%= button_tag action[:label], type: "button", disabled: true, data: action[:data] %>
  <% end %>
<% end %>
```

`tree_view_toolbar_supported_actions` は、documented public action symbol を返します。現時点では `:expand_all`、`:collapse_all`、`:collapse_all_except_current_path` です。host app が対応 action 全体を列挙したい場合は、internal constant ではなくこの helper を使ってください。

各 action hash には次が入ります。

- `:action` 例: `:expand_all`
- `:state` 例: `:expanded`
- `:label`
- `:path`。現在の mode が tree 全体 toggle を持たない場合は `nil`
- `:disabled`
- host app 側の button / link に使う `:data`

TreeView は metadata だけを提供します。最終的な HTML 構造、style、icon、認可ルールは host app 側で決めます。

## client-side開閉

`max_render_depth` / `max_leaf_distance` の範囲内の node を初期 HTML に含めても問題ない小〜中規模 tree では、`build_client_side` を使えます。Turbo route や Turbo Stream response を用意せず、browser 内だけで開閉します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_client_side

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

client-side mode では、collapsed descendants も初期 HTML に描画し、初期状態では `hidden` 属性で隠します。bundled `tree-view-client` controller が、現在の tree element 内だけで `hidden`、`aria-expanded`、TreeView row state data を同期します。lazy loading、children pagination、認可、server-side query 削減の代替ではありません。

client-side mode と `lazy_loading: { enabled: true }` は併用しないでください。client-side mode は初期 DOM に存在する row だけを表示できるため、後から children を取得する必要がある場合は Turbo mode を使います。

TreeView JavaScript controller を通常どおり登録します。

```js
import { application } from "controllers/application"
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Tree root element には `tree_view_state_data` を付けます。

```erb
<%= tag.table class: "tree-view-table", data: tree_view_state_data(@render_state) do %>
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
<% end %>
```

client-side mode では、開閉両方に使う toggle button icon は1種類だけを標準サポートします。見た目を開閉状態で変えたい場合は、host app 側の CSS で `aria-expanded` を使って調整できます。

```css
.tree-toggle__client-action[aria-expanded="false"] .tree-toggle__client-icon::before {
  content: "▶";
}

.tree-toggle__client-action[aria-expanded="true"] .tree-toggle__client-icon::before {
  content: "▼";
}
```

## 通常Tree

親子関係を持つ records から tree を作る場合は、`records:` と `parent_id_method:` を指定します。

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

`initial_state` は省略できます。省略した場合は global config、さらに未設定なら `:expanded` が使われます。

## View

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

windowed rendering を使う場合は、`window:` を渡します。

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

current row anchoring や Turbo refresh をまたぐ offset handoff の考え方は [Windowed Rendering](windowed-rendering.md) を参照してください。

## Row partial

host app 固有の列は `row_partial` に実装します。

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

この partial には常に `item`、`tree`、`render_state`、`row_context` が渡されます。`RenderState#node_presenter` を設定した場合は `node_presenter` も渡されるので、shared な label / href / tooltip / badge / action resolver を `row_locals` で手渡しし直さずに使えます。

Edit、Show、Delete、Archive などの行単位 action link / button には `row_actions_partial` を使います。表示列、action link、inline control、depth label、badge、icon、status marker の例は [Cookbook: 行 customization quick guide](cookbook.md#行customization-quick-guide) を参照してください。

## 行内のinteractive control

host app は `row_partial` や `row_actions_partial` の中に、input、select、textarea、button、link、`contenteditable` label を配置できます。TreeView はこれらの native interactive element を host app 側の control として扱い、それらから発生した event では TreeView の keyboard navigation や transfer drag start を実行しません。

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

`row_actions_partial` には `row_partial` と同じ `item`、`tree`、`render_state`、`row_context` が渡され、`node_presenter` を設定していれば同じく参照できます。

native control ではない custom widget では、row 内の widget またはその祖先に `data-tree-view-interactive="true"` を付けます。

```erb
<td>
  <span data-tree-view-interactive="true" contenteditable="true"><%= item.name %></span>
</td>
```

特定の TreeView 動作だけを無視したい場合は、より狭い marker を使えます。

- `data-tree-view-ignore-keyboard="true"` は、arrow key、space、enter による TreeView keyboard navigation を抑止します。
- `data-tree-view-ignore-row-click="true"` は、host app 側の row click 連携向けに予約されています。
- `data-tree-view-ignore-drag="true"` は、その control から TreeView transfer drag start が始まることを抑止します。

これらの marker は TreeView 側の動作を無視するためのものです。validation、保存、認可、CRUD route、inline editing flow は引き続き host app 側で実装します。

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

個別引数と grouped option を同時に指定した場合は、後方互換性のため個別引数を優先します。

### 現在のブランチだけを開いた状態で始める

collapsed を既定にしつつ、現在の record を含む branch だけを開きたい場合は、`current_item:` または `current_key:` と `auto_expand_ancestors: true` を組み合わせます。

```ruby
current_key = @document ? node_key(@document) : node_key(@project)

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    current_key: current_key,
    auto_expand_ancestors: true
  }
)
```

host app 側が current record object をそのまま持っている場合は、`current_key:` の代わりに `current_item:` を渡せます。

```ruby
initial_expansion: {
  default: :collapsed,
  current_item: @document,
  auto_expand_ancestors: true
}
```

`auto_expand_ancestors:` は、`root_items` 配下で current node を解決し、その祖先 key だけを `expanded_keys` に加えます。別の sibling branch や追加 path も最初から開きたい場合は、引き続き `expanded_keys:` を併用してください。

## Selection

checkbox selection を使う場合は `selection:` を指定します。

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

checkbox の描画、payload 生成、JavaScript controller による収集は TreeView が担当します。削除・移動・関連付けなどの業務処理は host app 側で実装します。

詳しくは [Selection](selection.md) を参照してください。

## Lazy loading

子 node を必要なタイミングで読み込む場合は、`load_children_path_builder` と `RenderState#lazy_loading` を使います。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
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

fetch、Turbo request、retry、loading message、認可は host app 側で実装します。Lazy loading は Turbo / server-driven rendering を前提とし、`build_client_side` とは併用できません。

## PathTree / ReverseTree

検索結果などから親階層を補完して表示する場合は `path_tree_for` を使います。

```ruby
path_tree = base_tree.path_tree_for(matched_documents)
```

子 node から親方向に辿る表示をしたい場合は `reverse_tree_for` を使います。

```ruby
reverse_tree = base_tree.reverse_tree_for(matched_documents)
```

| API | 表示方向 | 用途 |
|---|---|---|
| `path_tree_for(items)` | root → parent → matched item | 通常の階層構造内で検索結果を確認する |
| `reverse_tree_for(items)` | matched item → parent → root | 子 node 一覧から親方向へ辿る |

## 次に読むもの

- [API概要](api-overview.md)
- [API仕様](api.md)
- [Cookbook: 行 customization quick guide](cookbook.md#行customization-quick-guide)
- [Cookbook: 現在のブランチだけ初期展開する](cookbook.md#現在のブランチだけ初期展開する)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)
