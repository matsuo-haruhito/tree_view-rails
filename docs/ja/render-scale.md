# Render scale

このページでは、大きなtreeを扱うときの描画量・HTML量・責務分担を説明します。

## 概要

TreeViewは、大きなtreeでも扱いやすいように複数の描画制御APIを提供します。

- `max_initial_depth`
- `max_render_depth`
- `max_leaf_distance`
- `TreeView::VisibleRows`
- `TreeView::RenderWindow`
- lazy loading hooks

ただし、TreeView gemはserver-side queryやdata fetching量そのものは制御しません。

## 最初に検討すること

1. 初期表示で本当に全nodeが必要か確認する。
2. `max_initial_depth` で初期展開を制限する。
3. `max_render_depth` や `max_leaf_distance` で描画範囲を制限する。
4. visible rowsが多い場合は windowed rendering を使う。
5. データ取得量を減らしたい場合は lazy loading / server-side pagination をhost app側で実装する。

## 初期展開を制限する

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_initial_depth: 1
)
```

## 描画範囲を制限する

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  render_scope: {
    max_depth: 3,
    max_leaf_distance: 2
  }
)
```

## windowed rendering

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

windowed renderingは、現在のvisible rowsをoffset/limitで切るだけです。server-side queryは変えません。

## lazy loading

子nodeを必要なときだけ読み込む場合は lazy loading を使います。

```ruby
lazy_loading: {
  enabled: true,
  loaded_keys: loaded_keys
}
```

実際のfetch、query、pagination、Turbo Stream responseはhost app側で実装します。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| render depth controls | yes | chooses settings |
| visible rows calculation | yes | no |
| window slicing | yes | renders controls |
| lazy loading hooks | yes | implements fetch/query |
| server-side pagination | no | yes |
| data loading strategy | no | yes |
| performance budget | signals only | yes |
