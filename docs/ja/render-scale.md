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

`TreeView::RenderWindow` はHTML出力を制御するためのAPIです。`offset` と `limit` を受け取りますが、現在のrender stateでvisibleになっているrowをsliceするだけです。server-side pagination API、database query optimizer、組み込みのvirtual scrolling機能ではありません。

## 最初に検討すること

1. 初期表示で本当に全nodeが必要か確認する。
2. `max_initial_depth` で初期展開を制限する。
3. `max_render_depth` や `max_leaf_distance` で描画範囲を制限する。
4. 小さなtreeでは、まず全体再描画のTurbo expand/collapseで十分か確認する。
5. visible rowsが多く、HTML出力量だけを減らしたい場合は windowed rendering を使う。
6. 子nodeを必要になるまで取得・描画したくない場合は lazy loading を使う。
7. 1つの親に大量のchildrenがあり、requestごとの取得件数を減らしたい場合は children pagination を使う。
8. scroll位置に応じたDOM仮想化が必要な場合は、host app側でvirtual scrollingを実装する。

## 判断表

| 目的 | まず使うもの | 減らせるもの | 境界 |
|---|---|---|---|
| 初期展開を減らす | `max_initial_depth` | 初回表示で開くrow | database record数はそれだけでは減りません。 |
| 描画depthを制限する | `max_render_depth` / `max_leaf_distance` | HTML描画対象になる子孫 | query量も減らしたい場合はhost app側でqueryを絞ります。 |
| expand/collapseごとにtree全体を再描画する | Turbo expand/collapse + render state再構築 | 小さなtreeでの実装複雑度 | toggleごとにhost appのquery、tree構築、partial rendering costは残ります。 |
| visible rowsの一部だけを描画する | `TreeView::RenderWindow` / `tree_view_rows(..., window:)` | 現在visibleなrowsから出力されるHTML | host app queryや取得済みrecord数は減りません。 |
| 子node取得を減らす | [Lazy Loading](lazy-loading.md) | 初期の子node取得と未読み込みchildrenのHTML | fetch、query、authorization、responseはhost appが実装します。最小controllerとTurbo Stream patternはLazy Loading docsを参照してください。 |
| 大量childrenをpage分割する | [Children Pagination](children-pagination.md) | 1requestあたりに取得するchildren | cursor、offset、limit、次page判定、query strategyはhost appが担当します。cursorとnext-page例はChildren Pagination docsを参照してください。 |
| full virtual scrollを行う | host app JavaScript | scroll位置に応じたDOM作業 | TreeViewの組み込みscope外です。 |

## 実装段階ごとのおすすめ

大きなtree対応は、次の順に広げると判断しやすくなります。

1. **Staticまたは全体再描画のTurbo**: 小さなtree向けです。controllerとTurbo Stream responseを単純に保て、host appはrequestごとにrender state全体を再構築できます。
2. **Render scope / windowed rendering**: dataはすでに手元にあるがHTML出力が大きい場合に使います。描画行数は減りますが、query量は減りません。
3. **Lazy Loading**: 全子孫を先に取得・準備することが重い場合に使います。host appは開かれた親のchildrenを読み込み、必要なTurbo Stream responseを返します。[Lazy Loading](lazy-loading.md) のコピー可能なpatternから始めてください。
4. **Children Pagination**: 1つの親に大量のchildrenがあり、1回のexpand requestで返す件数を制限したい場合に足します。[Children Pagination](children-pagination.md) のcursor、limit、next-page例を使います。
5. **Host app側virtualization**: scroll位置に応じたDOM仮想化がproduct要件になった場合だけ追加します。

全体再描画のexpand/collapseが遅く感じる場合は、ボトルネックがHTML量、host appのdata fetching、partial renderingのどれかを切り分けてください。HTML量だけが問題なら render scope や windowing が合います。query量やchildren数が問題なら lazy loading や children pagination を検討してください。

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

windowed renderingは、現在のvisible rowsをoffset/limitで切ります。TreeViewがすでに計算したvisible rowsのうち、HTMLとして出力する行数を制限するための機能です。

windowed rendering は以下を行いません。

- host appのserver-side queryを変える
- databaseから取得するrecord数を減らす
- 親ごとのchildrenをpage分割する
- scroll位置を監視する
- DOM virtualizationやinfinite scrollを実装する

tree dataがすでに手元にあり、現在visibleなrowをすべてHTMLとして出力すると大きすぎる場合に使います。data fetching量を減らしたい場合は、host app側で [Lazy Loading](lazy-loading.md) または [Children Pagination](children-pagination.md) を使ってください。scroll位置に応じた仮想化が必要な場合は、host app側で実装してください。

## lazy loading

子nodeを必要なときだけ読み込む場合は lazy loading を使います。

```ruby
lazy_loading: {
  enabled: true,
  loaded_keys: loaded_keys
}
```

TreeViewはchildren URLとrow state hookを描画します。実際のfetch、query、pagination、authorization、Turbo Stream responseはhost app側で実装します。controller、Turbo Stream、loaded/error/retry、authorization patternは [Lazy Loading](lazy-loading.md) を参照してください。

## children pagination

1つの親が大量のchildrenを持つ場合、host app側でchildrenを小さなpageに分けて取得します。

TreeViewはcursor、offset、limit、ordering、次page判定、response shapeを選びません。lazy-loading URLとrow data hookによる連携境界を提供します。cursor-based pagination、limit clamp、stable ordering、next-page UI、unloaded childrenとselection / drag-dropの関係は [Children Pagination](children-pagination.md) を参照してください。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| render depth controls | yes | chooses settings |
| visible rows calculation | yes | no |
| window slicing | yes | renders controls |
| lazy loading hooks | yes | implements fetch/query |
| children pagination algorithm | no | yes |
| server-side pagination | no | yes |
| data loading strategy | no | yes |
| authorization and product behavior | no | yes |
| infinite scroll / virtual scroll | no | yes |
| performance budget | signals only | yes |
