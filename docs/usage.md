# 使い方

## 基本構成

`tree_view` は、host app 側で取得したrecordsを `TreeView::Tree` に渡し、`TreeView::RenderState` と `tree_view_rows` helper を使って描画します。

既存どおり `tree_view/tree_row` partial を直接renderすることもできます。

## 通常Tree

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id
)
```

既定では、root / children は子孫数の昇順で並びます。

並び順を変えたい場合は `sorter:` を渡します。

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)
```

## static表示

開閉リンクを使わず、静的なツリーとして表示したい場合は `build_static` を使います。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static
```

## Turbo Stream開閉

Turbo Streamで開閉したい場合は、`build` にpath builderを渡します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "item").build(
  hide_descendants_path_builder: ->(item, depth, scope) {
    view_context.remove_descendants_item_path(item, depth: depth + 1, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    view_context.show_descendants_item_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    state == :collapsed ? view_context.items_path(collapsed: "all") : view_context.items_path
  }
)
```

## RenderState

画面単位の描画状態は `TreeView::RenderState` にまとめます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

`initial_state` は省略できます。省略した場合は global config、さらに未設定なら `:expanded` が使われます。

### grouped optionで指定する

描画範囲・初期展開・開閉範囲は、個別引数の代わりに概念単位でまとめて指定できます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  initial_expansion: {
    default: :collapsed,
    max_depth: 2,
    expanded_keys: expanded_keys,
    collapsed_keys: collapsed_keys
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

対応関係は以下です。

| grouped option | 個別引数 | 意味 |
|---|---|---|
| `initial_expansion[:default]` | `initial_state` | 初期状態。`:expanded` / `:collapsed` |
| `initial_expansion[:max_depth]` | `max_initial_depth` | 初期HTMLで展開描画する最大depth |
| `initial_expansion[:expanded_keys]` | `expanded_keys` | 初期表示時に展開するnode_key配列 |
| `initial_expansion[:collapsed_keys]` | `collapsed_keys` | 初期表示時に折りたたむnode_key配列 |
| `render_scope[:max_depth]` | `max_render_depth` | root基準の描画対象最大depth |
| `render_scope[:max_leaf_distance]` | `max_leaf_distance` | leaf基準の描画対象最大distance |
| `toggle_scope[:max_depth_from_root]` | `max_toggle_depth_from_root` | root基準の開閉操作範囲 |
| `toggle_scope[:max_leaf_distance]` | `max_toggle_leaf_distance` | leaf基準の開閉操作範囲 |

個別引数とgrouped optionを同時に指定した場合は、後方互換性のため個別引数を優先します。

```ruby
TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  max_render_depth: 1,
  render_scope: { max_depth: 3 }
)
# => max_render_depth は 1 として扱われる
```

未知のkeyを含む場合は、設定ミスに気づきやすいよう `ArgumentError` を発生させます。

## Controller例

```ruby
def index
  @projects = Project.order(:name).to_a

  tree = TreeView::Tree.new(
    records: @projects,
    parent_id_method: :parent_project_id
  )

  @tree_ui = TreeView::UiConfigBuilder.new(
    context: view_context,
    node_prefix: "project"
  ).build_static

  @render_state = TreeView::RenderState.new(
    tree: tree,
    root_items: tree.root_items,
    row_partial: "projects/tree_columns",
    ui_config: @tree_ui
  )
end
```

## View例（ERB）

```erb
<table class="tree-view-table">
  <thead>
    <tr>
      <th>level</th>
      <th>name</th>
      <th>owner</th>
    </tr>
  </thead>
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

`mode:` や `collapsed:` を明示したい場合は、helper引数で上書きできます。

```erb
<%= tree_view_rows(@render_state, mode: :static, collapsed: false) %>
```

既存のpartial直接render方式も維持されています。

```erb
<%= render partial: "tree_view/tree_row",
  collection: @render_state.root_items,
  as: :item,
  locals: {
    tree: @render_state.tree,
    row_partial: @render_state.row_partial
  } %>
```

## Row partial例（ERB）

```erb
<!-- app/views/projects/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

## Slimを使うhost appの場合

host app 側のviewやrow partialはSlimでも構いません。

gem本体のpartialはERBですが、host app側の `row_partial` は任意のテンプレートエンジンで実装できます。

```slim
table.tree-view-table
  thead
    tr
      th level
      th name
      th owner
  tbody
    = tree_view_rows(@render_state)
```

```slim
/ app/views/projects/_tree_columns.html.slim
td = item.name
td = item.owner_name
```

## 用途別サンプル

### 通常Treeを `tree_view_rows` で描画する

通常の親子階層をそのまま表示する場合は、`tree.root_items` を `RenderState` に渡します。

```ruby
tree = TreeView::Tree.new(
  records: @documents,
  parent_id_method: :parent_document_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui
)
```

### `PathTree` で検索結果の親階層を補完する

検索結果や絞り込み結果を、通常の階層構造の中で見せたい場合は `path_tree_for` を使います。

表示方向は root → parent → matched item です。

```ruby
matched_documents = Document.search(params[:q]).to_a

base_tree = TreeView::Tree.new(
  records: Document.order(:name).to_a,
  parent_id_method: :parent_document_id
)

path_tree = base_tree.path_tree_for(matched_documents)

@render_state = TreeView::RenderState.new(
  tree: path_tree,
  root_items: path_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  initial_state: :expanded
)
```

### `ReverseTree` で子nodeから親方向へ辿る

子node一覧を起点に、所属フォルダや上位階層を逆方向に確認したい場合は `reverse_tree_for` を使います。

表示方向は matched item → parent → root です。

```ruby
matched_documents = Document.search(params[:q]).to_a

base_tree = TreeView::Tree.new(
  records: Document.order(:name).to_a,
  parent_id_method: :parent_document_id
)

reverse_tree = base_tree.reverse_tree_for(matched_documents)

@render_state = TreeView::RenderState.new(
  tree: reverse_tree,
  root_items: reverse_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  initial_state: :expanded
)
```

`PathTree` と `ReverseTree` は似ていますが、表示方向が異なります。

| API | 表示方向 | 用途 |
|---|---|---|
| `path_tree_for(items)` | root → parent → matched item | 通常の階層構造内で検索結果を確認する |
| `reverse_tree_for(items)` | matched item → parent → root | 子node一覧から親方向へ辿る |

### 複数nodeをcheckboxで選択する

TreeView上で複数nodeを選択し、host app側のcontrollerで一括処理したい場合は `selection:` を指定します。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    payload_builder: ->(document) {
      {
        key: tree.node_key_for(document),
        id: document.id,
        type: document.class.name
      }
    }
  }
)
```

選択checkboxの `value` にはJSON文字列が入ります。

```json
{"key":1,"id":1,"type":"Document"}
```

host app側では、通常のformやTurbo formから送られた `params[:selected_nodes]` をparseして一括処理します。

```ruby
selected_nodes = Array(params[:selected_nodes]).map { |value| JSON.parse(value) }
selected_ids = selected_nodes.map { |node| node["id"] }
```

TreeView gem は、checkboxの描画と選択payloadの受け渡しまでを担当します。
削除・移動・関連付けなどの業務処理やAPI呼び出しはhost app側で実装します。
親子連動選択、indeterminate表示、選択状態の永続化は初期実装の対象外です。

### nodeごとにcheckboxをdisabledにする

選択できないnodeがある場合は、`disabled_builder` を使います。
理由を表示したい場合は `disabled_reason_builder` も指定できます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  selection: {
    enabled: true,
    disabled_builder: ->(document) { document.archived? },
    disabled_reason_builder: ->(document) {
      document.archived? ? "アーカイブ済みのため選択できません" : nil
    }
  }
)
```

`disabled_reason_builder` の戻り値は、checkboxの `title` と `data-tree-selection-disabled-reason` に出力されます。

### checkboxを初期選択状態にする

既に関連付け済みのnodeや、編集画面で保存済みの選択状態を再現したい場合は `selected_keys` を使います。

```ruby
selected_keys = selected_documents.map { |document| tree.node_key_for(document) }

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  selection: {
    enabled: true,
    selected_keys: selected_keys
  }
)
```

`selected_keys` は `tree.node_key_for(item)` と照合されます。
disabled checkbox でも checked 表示はできますが、HTML仕様上 disabled checkbox はform送信されません。既存関連状態を表示する用途で使う場合は、送信値が必要かどうかをhost app側で考慮してください。

### 初期状態を折りたたみにする

最初はrootだけ表示し、ユーザー操作で展開したい場合は `initial_state: :collapsed` を指定します。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  initial_state: :collapsed
)
```

### `expanded_keys` で特定nodeまで開く

検索結果や現在選択中のnodeまで初期表示したい場合は、対象nodeだけでなく祖先nodeのkeyも `expanded_keys` に含めます。

```ruby
current_document = Document.find(params[:id])
path = tree.path_for(current_document)
expanded_keys = path.map { |document| tree.node_key_for(document) }

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  initial_state: :collapsed,
  expanded_keys: expanded_keys
)
```

### `collapsed_keys` で特定nodeだけ初期折りたたみにする

基本は展開しつつ、特定node配下だけ初期表示で閉じたい場合は `collapsed_keys` を指定します。

```ruby
large_folder = Document.find(params[:large_folder_id])

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  initial_state: :expanded,
  collapsed_keys: [tree.node_key_for(large_folder)]
)
```

`collapsed_keys` は `tree.node_key_for(item)` と照合されます。
同じnode_keyを `expanded_keys` と `collapsed_keys` の両方に指定した場合は、矛盾として `ArgumentError` になります。
親nodeが `collapsed_keys` に含まれている場合、その配下の子nodeを `expanded_keys` に入れても初期HTMLには表示されません。

### `max_initial_depth` で初期HTMLの展開範囲を制御する

`max_initial_depth` は、初期HTMLにどこまで展開描画するかを制御します。

境界depthのnodeは表示されますが、子孫は初期HTMLには出ません。子孫がある場合は `hidden_count` が表示されます。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  max_initial_depth: 1
)
```

### `max_render_depth` で描画対象そのものを制限する

`max_render_depth` は、root側から何階層までを描画対象にするかを制御します。

`max_initial_depth` と異なり、対象外nodeは `hidden_count` にも含めません。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  max_render_depth: 2
)
```

### `max_leaf_distance` でleaf側から描画対象を制限する

末端に近いnodeだけ見たい場合は `max_leaf_distance` を使います。

leafはdistance `0`、leafの親は `1`、leafの祖父は `2` として扱います。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  max_leaf_distance: 2
)
```

複数leafを持つnodeでは、最短leaf距離を使います。

### `max_toggle_depth_from_root` でroot基準の開閉範囲を渡す

`scope_format: :object` を指定すると、path builderの第3引数に `TreeView::ToggleScope` が渡されます。

root基準でまとめて開閉したい範囲は `max_toggle_depth_from_root` で指定します。

```ruby
@tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "document").build(
  scope_format: :object,
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_path(
      item,
      current_depth: depth,
      toggle_depth: scope.toggle_depth,
      scope: scope.mode
    )
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_path(
      item,
      current_depth: depth,
      toggle_depth: scope.toggle_depth,
      scope: scope.mode
    )
  },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  max_toggle_depth_from_root: 2
)
```

### `max_toggle_leaf_distance` でleaf基準の開閉範囲を渡す

leaf側から見た開閉範囲をpath builderに渡したい場合は `max_toggle_leaf_distance` を使います。

```ruby
@tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "document").build(
  scope_format: :object,
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_path(
      item,
      current_depth: depth,
      toggle_leaf_distance: scope.toggle_leaf_distance,
      leaf_scope: scope.leaf_distance_within_scope?
    )
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_path(
      item,
      current_depth: depth,
      toggle_leaf_distance: scope.toggle_leaf_distance,
      leaf_scope: scope.leaf_distance_within_scope?
    )
  },
  toggle_all_path_builder: ->(state) { documents_path(state: state) }
)

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  max_toggle_leaf_distance: 2
)
```

### 行にclassやdata属性を付与する

行ごとに状態表示やJavaScript連携用の属性を付けたい場合は、`row_class_builder` と `row_data_builder` を使います。

```ruby
@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: @tree_ui,
  row_class_builder: ->(document) {
    ["document-row", ("is-archived" if document.archived?)]
  },
  row_data_builder: ->(document) {
    {
      document_id: document.id,
      status: document.status
    }
  }
)
```

`data-tree-depth` は常に維持されます。

### 行イベント連携

`tree-view-transfer` は、行同士の操作を host app にイベントとして渡すための controller です。
実際の親変更や並び替え保存は host app 側で実装します。

```erb
<tbody data-controller="tree-view-transfer">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

行には `row_data_builder` で payload を渡します。

```ruby
row_data_builder: ->(item) {
  { tree_transfer_payload: { key: tree.node_key_for(item), id: item.id }.to_json }
}
```

利用する画面側で、必要な `draggable` 属性や `dragstart->tree-view-transfer#start` などを追加してください。

## mode指定

`mode:` を明示する場合は、`:static` または `:turbo` のみ指定できます。

```erb
<%= tree_view_rows(@render_state, mode: :static) %>
```

不正なmodeを指定すると `ArgumentError` になります。

## Global config

```ruby
TreeView.configure do |config|
  config.initial_state = :expanded
end
```
