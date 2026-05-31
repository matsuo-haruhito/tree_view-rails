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
