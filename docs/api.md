# API仕様

このドキュメントでは、`tree_view` の主要な公開APIと役割を整理します。

## TreeView::Tree

親子データをツリーとして扱うための中心オブジェクトです。

### records mode

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  id_method: :id,
  orphan_strategy: :ignore
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `records:` | yes | ツリー化するレコード配列 |
| `parent_id_method:` | yes | 親IDを返すメソッド名 |
| `id_method:` | no | 自身のIDを返すメソッド名。既定値は `:id` |
| `sorter:` | no | root / children の並び順を決めるcallable |
| `orphan_strategy:` | no | records内に親が存在しないnodeの扱い。既定値は `:ignore` |

### resolver mode

```ruby
tree = TreeView::Tree.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `roots:` | yes | root node 配列 |
| `children_resolver:` | yes | nodeからchildrenを返すcallable |
| `node_key_resolver:` | no | node_keyを返すcallable |
| `id_method:` | no | node_key_resolver未指定時に使うIDメソッド |
| `sorter:` | no | root / children の並び順を決めるcallable |

### adapter mode

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: ->(node) { node.children }
)

tree = TreeView::Tree.new(adapter: adapter)
```

`GraphAdapter` を使うことで、異種ノード混在ツリーを扱いやすくします。

### 主なメソッド

| メソッド | 説明 |
|---|---|
| `root_items(root_parent_id = nil)` | root node を返す |
| `children_for(record)` | 指定nodeのchildrenを返す |
| `parent_for(record)` | 指定nodeの親を返す。records modeのみ |
| `ancestors_for(record)` | root側から親までの祖先配列を返す。records modeのみ |
| `path_for(record)` | root側から指定nodeまでのpath配列を返す。records modeのみ |
| `paths_for(items)` | 複数nodeのpath配列を返す。records modeのみ |
| `path_tree_for(items)` | 複数nodeから親階層を補完した通常向きTreeを返す。records modeのみ |
| `reverse_tree_for(items)` | 複数nodeを起点に親方向へ辿る逆向きTreeを返す。records modeのみ |
| `descendant_counts` | node_keyごとの子孫数を返す |
| `node_key_for(record)` | nodeを識別するkeyを返す |
| `sort_items(items)` | sorterに従ってitemsを並び替える |
| `orphan_items` | records内に親が存在しないnodeを返す |
| `validate_unique_node_keys!` | node_key の重複を検出する開発時向けチェック |

### 並び順

既定では、子孫数の昇順で並びます。

```ruby
TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  sorter: ->(nodes, _tree) { nodes.sort_by(&:name) }
)
```

`sorter` は `call(items, tree)` できるオブジェクトを指定します。
`sorter` の戻り値は `to_a` に応答する配列相当のオブジェクトにしてください。
`nil` など配列相当ではない値を返した場合は、誤実装に気づきやすいよう `ArgumentError` を発生させます。

### 親方向 path helper

records mode では、検索結果や子ノード一覧から親階層を確認するための補助APIを使えます。

```ruby
tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id
)

paths = tree.paths_for(matched_documents)
expanded_keys = paths.flatten.map { |item| tree.node_key_for(item) }.uniq
```

| メソッド | 戻り値 |
|---|---|
| `parent_for(item)` | `item` の親。親IDが `nil`、または親がrecords内に存在しない場合は `nil` |
| `ancestors_for(item)` | root側から親までの祖先配列 |
| `path_for(item)` | root側から `item` までの配列 |
| `paths_for(items)` | 複数itemに対する `path_for` の配列 |
| `path_tree_for(items)` | 複数itemに対するpathを通常向きTreeとしてまとめた `TreeView::PathTree` |
| `reverse_tree_for(items)` | 複数itemに対するpathを子 → 親方向のTreeとしてまとめた `TreeView::ReverseTree` |

親がrecords内に存在しない orphan node の場合、`parent_for` は `nil`、`ancestors_for` は空配列、`path_for` は対象nodeのみを返します。
親方向の循環参照を検出した場合は `ArgumentError` を発生させます。
これらの親方向helperは records mode 専用です。resolver mode / adapter mode では利用できません。

`path_tree_for` は、検索結果などを起点に root → ancestor → matched item の通常向きTreeを作ります。
共通祖先や共通edgeは重複表示されません。

```ruby
path_tree = tree.path_tree_for(matched_documents)

render_state = TreeView::RenderState.new(
  tree: path_tree,
  root_items: path_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :expanded
)
```

`reverse_tree_for` は、検索結果などを起点に matched item → parent → root の逆向きTreeを作ります。

```ruby
reverse_tree = tree.reverse_tree_for(matched_documents)

render_state = TreeView::RenderState.new(
  tree: reverse_tree,
  root_items: reverse_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :expanded
)
```

## TreeView::PathTree

`TreeView::PathTree` は、`TreeView::Tree#path_tree_for(items)` から生成される、親階層補完済みの通常向きTreeです。

既存の `RenderState` / `tree_view_rows` と接続できるよう、通常Treeに近いインターフェースを持ちます。

| メソッド | 説明 |
|---|---|
| `root_items(root_parent_id = nil)` | PathTree内のroot nodeを返す |
| `children_for(record)` | PathTree内で指定nodeのchildrenを返す |
| `descendant_counts` | PathTree内の子孫数を返す |
| `node_key_for(record)` | base treeの `node_key_for` に委譲する |
| `sort_items(items)` | base treeの `sort_items` に委譲する |

`PathTree` は、base tree 全体ではなく、指定itemへ至るpath上のnodeだけを描画対象にします。
表示方向は通常Treeと同じ root → parent → matched item です。

## TreeView::ReverseTree

`TreeView::ReverseTree` は、`TreeView::Tree#reverse_tree_for(items)` から生成される、子ノード起点の逆向きTreeです。

既存の `RenderState` / `tree_view_rows` と接続できるよう、通常Treeに近いインターフェースを持ちます。

| メソッド | 説明 |
|---|---|
| `root_items(root_parent_id = nil)` | 起点となる matched item を返す |
| `children_for(record)` | ReverseTree内で指定nodeの親方向nodeを返す |
| `descendant_counts` | ReverseTree内の子孫数を返す。ここでの子孫は表示上の子、つまり親方向node |
| `node_key_for(record)` | base treeの `node_key_for` に委譲する |
| `sort_items(items)` | base treeの `sort_items` に委譲する |

`ReverseTree` は matched item → parent → root の向きで表示します。
通常向きの親階層補完Treeとは用途が異なります。

| API | 表示方向 | 主な用途 |
|---|---|---|
| `path_tree_for(items)` | root → parent → matched item | 検索結果を通常の階層構造内で確認する |
| `reverse_tree_for(items)` | matched item → parent → root | 子ノード一覧を起点に親方向へ辿る |

複数の起点nodeが同じ親・祖先を共有する場合、同じnodeを複数箇所に描画するとDOM IDが重複します。
そのため `ReverseTree` では、共有された親方向nodeは最初に現れたreverse pathにのみ接続します。
後続の起点nodeから同じ共有祖先へは接続しません。
同じ祖先を各起点node配下に重複表示したい場合は、DOM ID生成やnode_keyを分離する別設計が必要です。

### orphan node の扱い

records mode では、`parent_id_method` が返す親IDが `nil` ではなく、かつ同じ `records` 内に親レコードが存在しないnodeを orphan node として扱います。

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  orphan_strategy: :as_root
)
```

| `orphan_strategy` | `root_items(nil)` の挙動 |
|---|---|
| `:ignore` | 通常rootのみを返す。既定値で、従来互換の挙動 |
| `:as_root` | 通常rootに orphan node を加えて返す |
| `:raise` | orphan node が存在する場合に `ArgumentError` を発生させる |
| `:orphans_only` | orphan node のみをrootとして返す |

`root_items(parent_id)` のように親IDを明示した場合は、orphan strategy の影響を受けず、従来どおり指定した親IDのchildrenを返します。

`orphan_items` は、strategyに関係なく orphan node の一覧を返します。
resolver mode / adapter mode では orphan strategy は `:ignore` のみ有効です。

`:orphans_only` は、不正データ検出・メンテナンス画面向けに orphan node だけをrootとして表示したい場合に使います。orphan node のchildrenは通常どおり `children_for` で辿れます。

### node_key の重複検出

`validate_unique_node_keys!` は、開発時・テスト時に node_key の重複を明示的に検出するための optional API です。

```ruby
tree.validate_unique_node_keys!
```

node_key が重複している場合は、対象キーが分かる `ArgumentError` を発生させます。
本番描画時に常に検証するものではなく、必要な画面やテストで明示的に呼び出す想定です。

このAPIは node_key の重複検出のみを扱います。DOM ID の衝突検出は `RenderState#validate_unique_dom_ids!` で別APIとして提供されます。

## TreeView::VisibleRows

`TreeView::VisibleRows` は、現在の `RenderState` に基づいて表示対象となる行を一次元配列として取り出す public API です。

```ruby
visible_rows = TreeView::VisibleRows.new(
  tree: tree,
  root_items: tree.root_items,
  render_state: render_state
).to_a
```

各行は以下を持ちます。

| 属性 | 説明 |
|---|---|
| `item` | 元の node |
| `depth` | root 基準の depth |
| `node_key` | `tree.node_key_for(item)` の値 |
| `parent_key` | 親行の node_key。root は `nil` |
| `has_children?` | 表示元 tree 上で child を持つか |
| `expanded?` | 現在の render state で展開扱いか |

`VisibleRows` は `max_initial_depth`、`max_render_depth`、`max_leaf_distance`、`expanded_keys`、`collapsed_keys`、`initial_state` を反映します。既存の recursive partial rendering を置き換えるものではなく、host app 側の windowing、keyboard model、inspection、export などの基盤として使う想定です。

## TreeView::GraphAdapter

異種ノード混在ツリーの接続を表現するためのadapterです。

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: [country],
  children_resolver: ->(node) { ... },
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `roots:` | yes | root node 配列 |
| `children_resolver:` | yes | nodeからchildrenを返すcallable |
| `node_key_resolver:` | no | node_keyを返すcallable |

## TreeView::RenderState

画面単位の描画状態をまとめるオブジェクトです。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: tree_ui,
  initial_state: :expanded,
  max_initial_depth: 2,
  max_render_depth: 2,
  max_leaf_distance: 2,
  max_toggle_depth_from_root: 2,
  max_toggle_leaf_distance: 2,
  expanded_keys: [root_key, child_key],
  row_class_builder: ->(item) { item.archived? ? "is-archived" : nil },
  row_data_builder: ->(item) { { status: item.status } }
)
```

| 引数 | 必須 | 説明 |
|---|---:|---|
| `tree:` | yes | `TreeView::Tree` 相当のオブジェクト |
| `root_items:` | yes | 描画するroot node配列 |
| `row_partial:` | yes | host app側の列描画partial |
| `ui_config:` | yes | `TreeView::UiConfig` |
| `initial_state:` | no | `:expanded` または `:collapsed` |
| `max_initial_depth:` | no | 初期表示時に展開描画する最大depth。rootは `0` |
| `max_render_depth:` | no | 描画対象にする最大depth。rootは `0` |
| `max_leaf_distance:` | no | 描画対象にする最大leaf距離。leafは `0` |
| `max_toggle_depth_from_root:` | no | root基準で、開閉操作時にまとめて扱う最大depth |
| `max_toggle_leaf_distance:` | no | leaf基準で、開閉操作時にまとめて扱う最大leaf距離 |
| `expanded_keys:` | no | 初期表示時に展開するnode_key配列 |
| `initial_expansion:` | no | 初期展開状態をまとめるHash相当のオプション |
| `render_scope:` | no | 描画対象範囲をまとめるHash相当のオプション |
| `toggle_scope:` | no | 開閉操作範囲をまとめるHash相当のオプション |
| `selectable:` | no | checkbox選択を有効にするか。`true` / `false` |
| `selection_payload_builder:` | no | checkbox valueに入れるpayload Hashを返すcallable |
| `selection_checkbox_name:` | no | checkboxのname属性。既定値は `selected_nodes[]` |
| `selection:` | no | checkbox selectionをまとめるHash相当のオプション |
| `row_class_builder:` | no | `tr` に付与するCSS classを返すcallable |
| `row_data_builder:` | no | `tr` に付与するdata属性Hashを返すcallable |
| `lazy_loading:` | no | lazy loading 用の state と scope をまとめるHash相当のオプション |

`effective_initial_state` は、画面固有指定、global config、既定値の順で解決します。

scope / expansion 系の設定は、従来の個別引数に加えて、以下の grouped option でも指定できます。
個別引数と grouped option を同時に指定した場合は、後方互換性のため個別引数を優先します。
未知のkeyを含む場合は、設定ミスに気づきやすいよう `ArgumentError` を発生させます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :expanded,
    max_depth: 2,
    expanded_keys: [root_key, child_key]
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

| grouped option | 許可key | 対応する個別引数 |
|---|---|---|
| `initial_expansion:` | `:default` | `initial_state:` |
| `initial_expansion:` | `:max_depth` | `max_initial_depth:` |
| `initial_expansion:` | `:expanded_keys` | `expanded_keys:` |
| `initial_expansion:` | `:collapsed_keys` | `collapsed_keys:` |
| `render_scope:` | `:max_depth` | `max_render_depth:` |
| `render_scope:` | `:max_leaf_distance` | `max_leaf_distance:` |
| `toggle_scope:` | `:max_depth_from_root` | `max_toggle_depth_from_root:` |
| `toggle_scope:` | `:max_leaf_distance` | `max_toggle_leaf_distance:` |

`selection:` ではcheckbox selectionをまとめて指定できます。
個別引数と `selection:` を同時に指定した場合は、後方互換性と明示性のため個別引数を優先します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    payload_builder: ->(item) {
      {
        key: tree.node_key_for(item),
        id: item.id,
        type: item.class.name
      }
    }
  }
)
```

| selection key | 対応する個別引数 | 説明 |
|---|---|---|
| `:enabled` | `selectable:` | checkbox列を描画するか |
| `:payload_builder` | `selection_payload_builder:` | checkbox valueに入れるpayload Hashを返すcallable |
| `:checkbox_name` | `selection_checkbox_name:` | checkboxのname属性 |

`lazy_loading:` では remote children 読み込み用の data 属性と状態をまとめて指定できます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: ["document:1"],
    scope: "children"
  }
)
```

| lazy_loading key | 説明 |
|---|---|
| `:enabled` | lazy loading 用 data 属性と remote-state hook を有効にする |
| `:loaded_keys` | 既に children を読み込んだ node_key 配列 |
| `:scope` | `UiConfig#load_children_path` に渡す scope 文字列。既定値は `"all"` |

`selection_payload_builder` を省略した場合は、`key` / `id` / `type` を持つpayloadを生成します。
checkboxの `value` にはJSON文字列が入ります。
TreeView gem はcheckboxの描画と選択payloadの受け渡しまでを担当し、削除・移動・関連付けなどの一括処理はhost app側で実装します。

`max_initial_depth` は `nil` または `0` 以上のIntegerを指定します。
`nil` の場合はdepth制限なし、`0` の場合はrootのみ、`1` の場合はrootとそのchildrenまでを初期HTMLに描画します。
境界depthのnodeは collapsed 扱いになり、子孫がある場合は `hidden_count` が表示されます。
`initial_state: :collapsed` の場合は全体collapsedが優先され、rootのみが初期表示されます。

`max_render_depth` は `nil` または `0` 以上のIntegerを指定します。
`nil` の場合は描画範囲のdepth制限なし、`0` の場合はrootのみ、`1` の場合はrootとそのchildrenまでを描画対象にします。
`max_initial_depth` と異なり、`max_render_depth` は描画対象そのものを制限するため、境界より深いnodeは初期HTMLに出ず、`hidden_count` も表示されません。
後から開閉操作で表示する対象としても扱わない用途を想定しています。

`max_leaf_distance` は `nil` または `0` 以上のIntegerを指定します。
`nil` の場合はleaf距離による描画範囲制限なし、`0` の場合はleafのみ、`1` の場合はleafとその親までを描画対象にします。
leaf distance は、leafを `0` として、leaf側からroot方向へ数えた距離です。
複数leafを持つnodeでは、最短leaf距離を採用します。
たとえば、あるnodeが一方のleafからは距離 `1`、別のleafからは距離 `3` の場合、そのnodeのleaf distanceは `1` です。
`max_render_depth` がroot基準であるのに対し、`max_leaf_distance` はleaf基準です。
`max_render_depth` と同様に描画対象そのものを制限するため、対象外nodeは初期HTMLに出ず、`hidden_count` も表示されません。
ただし、対象外nodeの子孫に描画対象nodeが存在する場合があるため、行を省略しても子側の探索は継続します。

`max_toggle_depth_from_root` は `nil` または `0` 以上のIntegerを指定します。
`scope_format: :object` の `UiConfig` と組み合わせると、path builder の第3引数 `scope` に `TreeView::ToggleScope` が渡されます。
`ToggleScope#toggle_depth` は、`current_depth < max_toggle_depth_from_root` のとき `max_toggle_depth_from_root` を返し、範囲外では `current_depth` を返します。
これにより、指定範囲内ではroot基準depthまでまとめて開閉し、指定範囲外ではそのnode単体の開閉として扱えます。
既存互換のため、path builder の第2引数 `depth` は従来どおり現在nodeのdepthです。

`max_toggle_leaf_distance` は `nil` または `0` 以上のIntegerを指定します。
`scope_format: :object` の `UiConfig` と組み合わせると、`TreeView::ToggleScope` に現在nodeのleaf distanceと最大leaf distanceが渡されます。
leaf distance は `max_leaf_distance` と同じく、leafを `0` とした最短leaf距離です。
`ToggleScope#toggle_leaf_distance` は、`current_leaf_distance < max_toggle_leaf_distance` のとき `max_toggle_leaf_distance` を返し、範囲外では `current_leaf_distance` を返します。
これにより、leafに近い範囲ではleaf基準distanceまでまとめて開閉し、範囲外ではそのnode単体の開閉として扱えます。
`render_scope` / `initial_expansion` と異なり、描画対象や初期展開状態は変えず、開閉path builderに渡す操作範囲だけを変えます。
path builder 側では `scope.toggle_leaf_distance` や `scope.leaf_distance_within_scope?` を参照できます。

`expanded_keys` には `tree.node_key_for(item)` と一致する値を指定します。
該当nodeは `initial_state: :collapsed` や `max_initial_depth` の境界指定より優先して展開されます。
ただし、親が初期HTMLに描画されていない場合、子だけを `expanded_keys` に指定しても表示されません。
対象ノードまで表示したい場合は、対象ノードだけではなく、その祖先nodeのkeyも一緒に指定してください。

`row_class_builder` は文字列、配列、または `nil` を返せます。
`row_data_builder` はHash相当の値、または `nil` を返せます。
既存の `data-tree-depth` は常に維持されます。

lazy loading が有効で `UiConfig#load_children_path(item, depth, scope:)` がURLを返す場合、行には `data-tree-lazy`、`data-tree-children-url`、`data-tree-loaded` が付きます。
また、`loaded_keys` に含まれる行は `data-remote-state="loaded"` を持ちます。`loading_builder` / `error_builder` を併用する場合は、それぞれ `loading` / `error` が優先されます。

## TreeView::UiConfig

DOM IDや開閉pathの作り方をまとめるオブジェクトです。

主に `TreeView::UiConfigBuilder` から生成します。

### static

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static
```

staticでは開閉path builderを持ちません。

### turbo

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "item").build(
  hide_descendants_path_builder: ->(item, depth, scope) { ... },
  show_descendants_path_builder: ->(item, depth, scope) { ... },
  toggle_all_path_builder: ->(state) { ... },
  scope_format: :string
)
```

| builder | 説明 |
|---|---|
| `hide_descendants_path_builder` | 子孫を閉じるpathを返す |
| `show_descendants_path_builder` | 子孫を開くpathを返す |
| `load_children_path_builder` | remote children 読み込み用pathを返す |
| `toggle_all_path_builder` | 全体開閉pathを返す |
| `scope_format` | path builder 第3引数のscope形式。`:string` または `:object` |

`scope_format` の既定値は `:string` です。既存どおり path builder の第3引数には `"all"` のような文字列が渡されます。

`scope_format: :object` を指定すると、path builder の第3引数には `TreeView::ToggleScope` が渡されます。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "item").build(
  scope_format: :object,
  hide_descendants_path_builder: ->(item, depth, scope) {
    view_context.hide_item_path(
      item,
      current_depth: depth,
      toggle_depth: scope.toggle_depth,
      toggle_leaf_distance: scope.toggle_leaf_distance,
      scope: scope.mode
    )
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    view_context.show_item_path(
      item,
      current_depth: depth,
      toggle_depth: scope.toggle_depth,
      toggle_leaf_distance: scope.toggle_leaf_distance,
      scope: scope.mode
    )
  },
  toggle_all_path_builder: ->(state) { view_context.items_path(state: state) }
)
```

## TreeView::ToggleScope

root基準・leaf基準の開閉範囲情報をpath builderへ渡すための値オブジェクトです。

| メソッド | 説明 |
|---|---|
| `mode` | scope種別。現時点では `:all` |
| `current_depth` | 現在nodeのdepth |
| `max_depth_from_root` | root基準の開閉対象最大depth |
| `current_leaf_distance` | 現在nodeのleaf distance |
| `max_leaf_distance` | leaf基準の開閉対象最大distance |
| `toggle_depth` | root基準で実際に開閉対象として扱うdepth |
| `toggle_leaf_distance` | leaf基準で実際に開閉対象として扱うdistance |
| `within_scope?` | 現在nodeがroot基準またはleaf基準のまとめ開閉対象範囲内かどうか |
| `root_depth_within_scope?` | 現在nodeがroot基準のまとめ開閉対象範囲内かどうか |
| `leaf_distance_within_scope?` | 現在nodeがleaf基準のまとめ開閉対象範囲内かどうか |

`root_depth_within_scope?` は `current_depth < max_depth_from_root` のとき `true` です。
`leaf_distance_within_scope?` は `current_leaf_distance < max_leaf_distance` のとき `true` です。
境界値とそれより外側では `false` になり、そのnode単体の開閉として扱う想定です。

## TreeViewHelper

viewから使う補助helperです。

| メソッド | 説明 |
|---|---|
| `tree_view_rows(render_state)` | `RenderState` からroot行を描画する |
| `tree_node_dom_id(item_or_id)` | nodeのDOM IDを返す |
| `tree_button_dom_id(item)` | toggle cell用DOM IDを返す |
| `tree_show_button_dom_id(item)` | show button用DOM IDを返す |
| `tree_selection_checkbox_dom_id(item)` | selection checkbox用DOM IDを返す |
| `tree_selection_payload(item, tree, builder = nil)` | selection checkbox用payload Hashを返す |
| `tree_selection_value(item, tree, builder = nil)` | selection checkboxのvalue用JSON文字列を返す |
| `tree_hide_descendants_path(item, display_depth, scope: 'all')` | 閉じるpathを返す |
| `tree_show_descendants_path(item, toggle_depth, scope: 'all')` | 開くpathを返す |
| `tree_load_children_path(item, depth, scope: 'all')` | remote children 読み込みpathを返す |
| `tree_toggle_all_path(state:)` | 全体開閉pathを返す |
| `tree_expand_all_path` | 全体展開pathを返す |
| `tree_collapse_all_path` | 全体折りたたみpathを返す |
| `tree_branch_info(item, tree)` | 枝描画用情報を返す |
| `tree_toggle_mode(mode = nil)` | `:static` / `:turbo` を検証して返す |

`ui:` または `@tree_ui` が未設定のままDOM IDやpath系helperを呼ぶと、設定漏れが分かる `ArgumentError` を返します。

## TreeView::Traversal

子孫ID収集の補助モジュールです。

```ruby
map = TreeView::Traversal.child_ids_by_parent_id(pairs)
ids = TreeView::Traversal.descendant_ids(node_id, map, min_depth: 1, max_depth: 3)
```

| メソッド | 説明 |
|---|---|
| `child_ids_by_parent_id(pairs)` | `[id, parent_id]` の配列から親子mapを作る |
| `descendant_ids(node_id, child_ids_by_parent_id, min_depth:, max_depth:)` | 指定nodeの子孫IDを返す |

## Partial

TreeView本体は以下のpartialを提供します。

- `tree_view/tree_row`
- `tree_view/tree_children`
- `tree_view/tree_selection_cell`
- `tree_view/tree_toggle_cell`
- `tree_view/tree_toggle_content`
- `tree_view/tree_toggle_content_static`
- `tree_view/tree_toggle_content_turbo`

host app は `row_partial` を指定して、業務固有の列部分を描画します。
