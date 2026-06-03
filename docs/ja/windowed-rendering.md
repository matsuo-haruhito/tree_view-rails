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

windowed rendering が制御するのはHTML出力だけです。host app queryや取得済みrecord数は減りません。問題がdata loading量なら [Lazy Loading](lazy-loading.md) または [Children Pagination](children-pagination.md) から検討してください。scroll位置に応じたDOM仮想化が必要な場合は、host app側でvirtual scrollingを実装してください。

## tree_view_rows でwindowを指定する

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

この場合、現在の展開状態・描画範囲に基づいてvisible rowsを作り、そのうち先頭50件だけを描画します。

## tree_view_window helper

ページングmetadataが必要な場合は `tree_view_window` を使います。supported helper keyword surface は `offset:` と `limit:` です。この key set は `config/public_api_manifest.yml` で追跡し、pagination policy を TreeView の責務に広げずに compatibility check で drift を検知します。

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
| `before_count` | 現在のwindowより前にあるvisible row数。 |
| `after_count` | 現在のwindowより後ろに残るvisible row数。 |
| `has_previous?` | 前のwindowが存在するか。 |
| `has_next?` | 次のwindowが存在するか。 |
| `previous_offset` | 前のwindowを描画するときに渡すoffset。前のwindowがない場合は `nil`。 |
| `next_offset` | 次のwindowを描画するときに渡すoffset。次のwindowがない場合は `nil`。 |

`before_count` / `after_count` は summary 用metadataです。host app が「このwindowの前に20件ある」「このwindowの後ろに35件残っている」のような表示を作るとき、`offset` / `limit` / `total_count` から毎回再計算せずに利用できます。

どちらも負の値は返しません。指定されたoffsetがvisible row数を超える場合、`before_count` は `total_count` で止まり、`after_count` は `0` になります。

小さな host-app pagination cue は、summary count と offset を組み合わせて作れます。TreeView が route や UI policy を所有するわけではありません。

```ruby
limit = 50
window = tree_view_window(@render_state, offset: params.fetch(:tree_offset, 0).to_i, limit: limit)
```

```erb
<p>
  表示中: <%= window.rows.size %> / <%= window.total_count %> visible rows
  （前に <%= window.before_count %> 件、後ろに <%= window.after_count %> 件）
</p>

<%= link_to "Previous", documents_path(tree_offset: window.previous_offset) if window.has_previous? %>
<%= link_to "Next", documents_path(tree_offset: window.next_offset) if window.has_next? %>
```

表示文言、route helper、param 名、disabled button の扱い、リンク・ボタン・Turbo Frame toolbar のどれで出すかはすべて host app 側で決めます。

## Visual reference

`offset` / `limit` による切り出し、current-row anchoring、previous / next metadata を host-app 側の pagination behavior なしで静的に見比べたい場合は [windowed-rendering.html](../mockups/windowed-rendering.html) を参照してください。

この mockup は、このページの API 例を視覚的に補うためのものです。offset の持ち回り、pagination controls、route / query 設計は引き続き host app 側の責務です。

## current row を window 内に寄せる

navigation が多いtreeでは、常に offset `0` から始めるよりも、現在選択中の行を window の中央付近に保ちたいことがあります。

TreeView はどの行を "current" とみなすかを決めません。その意味付けは host app 側の責務です。host app は visible-row list から current row の位置を求めてから、最終的な `TreeView::RenderWindow` を組み立てられます。

```ruby
visible_rows = TreeView::VisibleRows.new(
  tree: @render_state.tree,
  root_items: @render_state.root_items,
  render_state: @render_state
).to_a

limit = 50
current_key = @render_state.tree.node_key_for(current_document)
current_index = visible_rows.index { |row| row.node_key == current_key } || 0
anchored_offset = [current_index - (limit / 2), 0].max
window = TreeView::RenderWindow.new(visible_rows, offset: anchored_offset, limit: limit)
```

この考え方は、route・selection state・server-driven navigation などから current record が決まっていて、その行を window 外へ落としにくくしたい場合に向いています。

展開状態、collapsed key、render scope が変わると visible rows 自体も変わるため、anchoring 前に visible rows を作り直してください。windowing は、それらの条件で表示対象が決まった後に適用されます。

## Turbo 更新時に offset を持ち回る

Turbo や他の server-driven refresh で tree を差し替える場合は、現在の offset を query param、hidden field、toolbar link など host app 管理の state に保持してください。

```ruby
limit = 50
requested_offset = params.fetch(:tree_offset, 0).to_i
window = tree_view_window(@render_state, offset: requested_offset, limit: limit)

if window.empty? && requested_offset.positive?
  window = tree_view_window(@render_state, offset: window.previous_offset || 0, limit: limit)
end
```

```erb
<%= link_to "Previous", documents_path(tree_offset: window.previous_offset) if window.has_previous? %>
<%= link_to "Next", documents_path(tree_offset: window.next_offset) if window.has_next? %>
```

`tree_offset` はあくまで例です。param 名、route 設計、どの interaction で offset を保つかは host app 側で決めます。

実運用では、node の開閉、current record の切り替え、tree を含む Turbo Frame の再描画など、tree を再描画する link や form で同じ offset を持ち回ると current context を失いにくくなります。

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

全データ取得量を減らしたい場合は、[Lazy Loading](lazy-loading.md)、[Children Pagination](children-pagination.md)、またはhost app側のdata-loading strategyを使ってください。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| visible rows calculation | yes | no |
| offset / limit slicing | yes | no |
| row rendering for a window | yes | calls helper |
| current-row meaning | no | yes |
| current-row anchoring policy | no | yes |
| pagination controls | metadata only | renders UI |
| offset persistence across refreshes | no | yes |
| URL/query state | no | yes |
| infinite scroll | no | yes |
| virtual scroll | no | yes |
| server-side pagination | no | yes |
| data fetching | no | yes |
