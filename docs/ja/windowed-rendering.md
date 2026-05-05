# Windowed Rendering

このページでは、表示対象行の一部だけを描画する windowed rendering を説明します。

## 概要

windowed rendering は、現在表示対象になっているvisible rowsを `offset` / `limit` で切り出して描画する opt-in API です。

大きなtreeで初期HTML量を抑えたい場合や、host app側でページングUIを作りたい場合に使います。

TreeView gem が担当するのは以下です。

- `TreeView::VisibleRows` で現在表示対象の行を一次元化する
- `TreeView::RenderWindow` で `offset` / `limit` による切り出しを行う
- `tree_view_rows(render_state, window: { offset:, limit: })` でwindow内の行だけを描画する
- previous / next availability などのmetadataを提供する

scroll監視、infinite scroll、URL query、server-side pagination、データ取得はhost app側で実装します。

## tree_view_rows でwindowを指定する

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

この場合、現在の展開状態・描画範囲に基づいてvisible rowsを作り、そのうち先頭50件だけを描画します。

## tree_view_window helper

ページングmetadataが必要な場合は `tree_view_window` を使います。

```ruby
window = tree_view_window(@render_state, offset: 0, limit: 50)
```

利用できる主な情報:

| API | 意味 |
|---|---|
| `rows` | window内のvisible rows。 |
| `offset` | 開始位置。 |
| `limit` | 最大件数。 |
| `total_count` | window適用前のvisible row数。 |
| `has_previous?` | 前のwindowが存在するか。 |
| `has_next?` | 次のwindowが存在するか。 |

## 展開状態との関係

windowingは、現在の展開状態・render scopeを適用した後のvisible rowsに対して行われます。

つまり、折りたたまれている子孫はvisible rowsに含まれず、window対象にもなりません。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed,
  expanded_keys: expanded_keys
)
```

この例では、`expanded_keys` によって表示対象になった行だけがwindowing対象になります。

## 用途

- 大きなtreeの初期HTML量を抑える
- visible rowsに対してページングUIを作る
- host app側の「もっと見る」ボタンと組み合わせる
- lazy loadingやserver-side paginationと組み合わせる前段階として使う

## 注意点

windowed rendering はDOM仮想化ではありません。

- scroll位置の監視はしません
- 自動で次windowを読み込みません
- server-side queryを変えません
- 全treeのデータ取得量を減らすものではありません

全データ取得量を減らしたい場合は、host app側でserver-side paginationやlazy loadingを組み合わせてください。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| visible rows calculation | yes | no |
| offset / limit slicing | yes | no |
| row rendering for a window | yes | calls helper |
| pagination controls | metadata only | renders UI |
| URL/query state | no | yes |
| infinite scroll | no | yes |
| server-side pagination | no | yes |
| data fetching | no | yes |
