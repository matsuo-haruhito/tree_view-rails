# FAQ

このページでは、TreeView が担当することと、host Rails app 側に残る責務について、よくある誤解を短く整理します。

## TreeView を入れるだけで DB query は減りますか？

いいえ。TreeView の render controls は、既に分かっている row のうち、どれを展開するか、表示するか、HTML として出すかを調整するものです。host app 側の query 数や取得 record 数を、そのまま減らすものではありません。

query 量が課題なら、host app 側で lazy loading や children pagination を使う段階に進んでください。

関連:

- [API判断ガイド](decision-guide.md)
- [Render Scale](render-scale.md)
- [Lazy Loading](lazy-loading.md)
- [Children Pagination](children-pagination.md)

## `TreeView::RenderWindow` を使うと取得データ量も減りますか？

いいえ。`TreeView::RenderWindow` や `tree_view_rows(..., window:)` は、現在の render state ですでに visible な rows を offset / limit で切り出すだけです。減るのは HTML 出力量だけです。

tree data はすでにあるが、visible row を全部出すと HTML が大きすぎる、というときに使ってください。children の取得量を減らしたい場合は、host app 側で lazy loading や children pagination を使います。

関連:

- [API判断ガイド](decision-guide.md)
- [Render Scale](render-scale.md)

## TreeView には full virtual scroll や infinite scroll が入っていますか？

いいえ。scroll 位置に応じた DOM virtualization や infinite scroll の制御は、host app または外部 JavaScript layer の責務です。

TreeView は row 描画、metadata、hook を提供できますが、built-in の virtual scrolling engine は持ちません。

関連:

- [API判断ガイド](decision-guide.md)
- [Render Scale](render-scale.md)
- [Host App Extension Points](host-app-extension-points.md)

## TreeView は full keyboard navigation や `treegrid` semantics を提供しますか？

いいえ。TreeView は table-based な row markup、展開control、selection state、row-level ARIA state、toggle action 向けの軽い focus styling を提供します。ただし、full WAI-ARIA treegrid role model、roving tabindex、page-level focus order、shortcut behavior は現在提供していません。

keyboard flow、caption、周辺control、shortcut、full treegrid interaction model を追加するかどうかは host app 側の責務です。

関連:

- [Accessibility Semantics](accessibility-semantics.md)
- [Host App Extension Points](host-app-extension-points.md)

## TreeView は CRUD 付きの file manager としてそのまま使えますか？

それ自体では使えません。TreeView は tree / tree table を描画するための rendering primitive であり、完成済みの file manager application ではありません。

record、controller、form、route、authorization、label、context menu、bulk action、永続化は host app 側が持ちます。TreeView を使って CRUD 寄りの file manager を組むことはできますが、その業務挙動は gem の外側です。

関連:

- [README の Out of scope](../../README.md#out-of-scope)
- [Rendering Boundaries](rendering-boundaries.md)
- [Form と編集行](form-editing.md)

## TreeView が認可や policy を処理してくれますか？

いいえ。authorization は host app 側の責務です。

TreeView は host app の path builder を呼んだり、host app の row partial を描画したりできますが、route のアクセス制御、policy check、query の絞り込み、Turbo response は application 側で実装します。

関連:

- [README の Out of scope](../../README.md#out-of-scope)
- [Rendering Boundaries](rendering-boundaries.md)
- [Host App Extension Points](host-app-extension-points.md)

## resolver mode や adapter mode でも TreeView が breadcrumb を推測しますか？

いいえ。bundled breadcrumb helper は records mode の tree と `tree.path_for(item)` を使い、現在 record から root までの path を辿ります。resolver mode、adapter mode、graph-like data では親方向の候補が複数あり得るため、TreeView はどの breadcrumb trail が正しいかを推測しません。

`GraphAdapter` や graph-like source の data では、host app 側で breadcrumb trail を選び、独自の link または label を描画してください。route、authorization、layout placement、analytics behavior も host app 側の責務です。

関連:

- [Breadcrumb: 対応mode](breadcrumb.md#対応mode)
- [Troubleshooting: breadcrumb が失敗する / 親方向の path が見つからない](troubleshooting.md#breadcrumb-が失敗する--親方向の-path-が見つからない)
- [GraphAdapter](graph-adapter.md)

## row が重複する / 消える / 描画前に失敗する場合はどこを見ますか？

row partial や JavaScript wiring を変える前に tree diagnostics から確認してください。node key の重複は展開状態や persisted state を不安定に見せることがあり、filter や permission scope で親が隠れると orphan が出ます。DOM ID collision は browser 向け target を壊し、cycle は parent path traversal を不正にします。

単一のリスクを test したい場合は、個別の描画前チェックを使います。`validate_node_keys: true`、`orphan_strategy:`、`render_state.validate_unique_dom_ids!`、`TreeView::CycleDiagnostics.new(tree).report`、大きな tree の戦略確認には `tree.stats` が入口です。複数の check をまとめて errors / warnings として見たい場合は `TreeView::Diagnostics.run` を使います。

TreeView はリスクを報告します。data correction、filtering policy、authorization scope、大きな tree の rendering strategy は host app 側の責務です。

関連:

- [Tree diagnostics](tree-diagnostics.md)
- [Troubleshooting](troubleshooting.md#duplicate-node-key--orphan--dom-id-collision--cycle-が出る)
- [Node keys](node-keys.md)

## persisted state が画面表示直後に保存されるのはなぜですか？

`tree-view-state:state-changed` event は、初回 connect 時にも、`refresh` や expand/collapse update 後にも dispatch されます。最初の event は現在の展開状態の snapshot であり、ユーザーが tree を変更した証拠ではありません。

TreeView は event を publish するだけです。host app がユーザー操作による変更だけを保存したい場合は、listener を debounce する、最初の event を無視する、host app 側の dirty-state policy で save を gate する、といった方針を host app 側で持ってください。

関連:

- [Persisted State](persisted-state.md)
- [JavaScript event contract](js-events.md)
- [Troubleshooting](troubleshooting.md)

## children pagination の SQL / cursor strategy は TreeView が決めますか？

いいえ。大きな child set に対する pagination algorithm、SQL の形、cursor 設計、ordering、next-page 判定は TreeView が決めません。

gem は lazy-loading URL や row hook を通じた integration boundary を提供します。children をどう取得し、どう page し、どう認可し、どう返すかは host app 側で決めます。

関連:

- [API判断ガイド](decision-guide.md)
- [Children Pagination](children-pagination.md)
- [Lazy Loading](lazy-loading.md)

## parent を選択すると、まだ読み込まれていない descendants も含まれますか？

いいえ。TreeView の checkbox cascade、indeterminate state、hidden input sync は描画済み DOM を読み取ります。対象になるのは、すでに page 上に存在する rows だけです。

unloaded descendants、後続 page の children、filtered child set 全体に bulk action を適用したい場合は、loaded-row checkbox payload に加えて、host app 側の server-side intent や query filter を送ってください。TreeView は、まだ描画していない record の authorization、query scope、bulk action semantics を決めません。

関連:

- [Selection: 連動checkbox挙動](selection.md#連動checkbox挙動)
- [Children Pagination: selection / drag-drop との相互作用](children-pagination.md#selection--drag-drop-との相互作用)
- [children-pagination-selection-boundary.html](../mockups/children-pagination-selection-boundary.html)