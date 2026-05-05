# Lazy Loading

このページでは、子nodeを必要なタイミングで読み込むためのTreeView hooksを説明します。

## 概要

lazy loading は、初期HTMLにすべての子孫を描画せず、ユーザー操作やhost app側のremote requestに応じて子nodeを追加表示するための機能です。

TreeView gem が担当するのは以下です。

- `load_children_path_builder` から children URL を生成する
- row data に children URL / loaded state を出力する
- `tree-view-remote-state` controller 用の data/action hook を出力する
- loading / loaded / error / retry event に反応するcontrollerを提供する

実際のfetch、Turbo request、controller action、認可、query、retry UI、children paginationはhost app側で実装します。

## UiConfigの設定

lazy loadingを使う場合は、`UiConfigBuilder#build` に `load_children_path_builder` を渡します。

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
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(state: state)
  }
)
```

`load_children_path_builder` はURLを作るだけです。

## RenderStateの設定

`RenderState` 側では `lazy_loading:` を指定します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: loaded_keys,
    scope: "children"
  }
)
```

| option | 意味 |
|---|---|
| `enabled:` | lazy loading用data属性を出すかどうか。 |
| `loaded_keys:` | すでにchildrenを読み込み済みのnode_key配列。 |
| `scope:` | path builderへ渡すscope。省略可能。 |

## 出力されるrow data

lazy loadingが有効で、`load_children_path_builder` がURLを返す場合、rowには概ね以下のようなdata属性が付きます。

```html
<tr
  data-tree-lazy="true"
  data-tree-children-url="/documents/1/children"
  data-tree-loaded="false">
</tr>
```

## Remote state controller

`tree_view_state_data(render_state)` は、lazy loading有効時に `tree-view-remote-state` controller と action hook を追加します。

```text
tree-view:loading->tree-view-remote-state#loading
tree-view:loaded->tree-view-remote-state#loaded
tree-view:error->tree-view-remote-state#error
tree-view:retry->tree-view-remote-state#retry
```

host app側は、fetchやTurbo requestの状態に応じてこれらのeventをdispatchできます。

## children pagination

大量のchildrenを少しずつ読み込む場合は、server-side paginationをhost app側で実装します。

TreeView側は、URL生成とrow data hookだけを提供します。cursor、page token、limit、offset、次ページ判定、追加Turbo Streamの内容はhost app側で決めます。

children paginationの詳細は [Children pagination](../children-pagination.md) を参照してください。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| children URL generation | yes | provides path builder |
| row data attributes | yes | consumes them |
| remote-state controller hooks | yes | dispatches events |
| fetching children | no | yes |
| Turbo Stream response | no | yes |
| authorization | no | yes |
| server-side pagination | no | yes |
| retry / error messaging | hook only | yes |
