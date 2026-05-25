# Troubleshooting

このページは、TreeView 統合時によくある詰まりを症状ベースでたどるための入口です。

「どこで困っているか」は分かるが、どの API 文書から読み直せばよいか迷うときに使ってください。

TreeView は描画プリミティブ、JavaScript hook、validation helper を提供します。routes、controller action、authorization、query、Turbo Stream response、business action、page layout は引き続き host app の責務です。

## toggle link を押しても展開・折りたたみされない

最初に tree mode を確認してください。

- `build_turbo` / `build` は host app 側の Turbo Stream endpoint を前提にします。
- `build_static` は静的な snapshot です。閉じた descendant は HTML に出ないため、browser 上で開けません。
- `build_client_side` は descendant が初期 HTML に含まれている前提で、TreeView JavaScript が表示・非表示を切り替えます。

次に、その mode に合った wiring を確認します。

- Turbo mode: `show_descendants_path_builder`、`hide_descendants_path_builder`、route、controller action、authorization、Turbo Stream response を host app 側で確認する
- client-side mode: TreeView controller が登録され、tree root に `tree_view_state_data(@render_state)` が出ているか確認する
- lazy loading は client-side toggle mode と同時には使えません

次に読む文書:

- [使い方](usage.md)
- [Turbo Frame option](turbo-frame.md)
- [Lazy Loading](lazy-loading.md)
- [導入手順](installation.md)

## row partial の表示が崩れる / table cell 数が合わない

TreeView は row wrapper と共通 tree UI cell を担当し、`row_partial` の中身、action cell、周囲の table layout は host app が担当します。

次の順で確認してください。

- page 全体の table wrapper が host app 側で意図どおり定義されているか
- row partial がその画面で必要な business column を描画しているか
- selection や resource-table bridge など optional cell を有効にした場合、host app 側 layout もその列数を前提にしているか
- 特定 record だけで崩れる場合、partial を直す前に node key と DOM ID を確認する

次に読む文書:

- [Rendering Boundaries](rendering-boundaries.md)
- [Resource table bridge](resource-table-bridge.md)
- [Selection](selection.md)
- [Accessibility Semantics](accessibility-semantics.md)
- [Tree diagnostics](tree-diagnostics.md)

## CSS や JavaScript の統合が効いていないように見える

まず導入 wiring を確認してください。

- stylesheet で `@import "tree_view";` を読み込む
- JavaScript を使うなら `pin "tree_view", to: "tree_view/index.js"` を追加する
- client-side toggle、selection、transfer hook、remote loading state など browser 側機能を使う場合は、host app 側で TreeView controller を登録する

責務境界も合わせて確認してください。

- static rendering 自体は TreeView JavaScript なしでも動きます
- selection cascade、client-side expand/collapse、transfer event、remote loading state は JavaScript controller が必要です
- CSS が当たらない場合は、host app 側 asset pipeline で gem stylesheet を読み込めていない可能性を先に見ます

次に読む文書:

- [導入手順](installation.md)
- [使い方](usage.md)
- [JavaScript event contract](js-events.md)

## TreeView partial の render log が見えない / 多すぎる

TreeView は helper-rendered partial の周辺だけ、既定で log level を下げて描画します。これは意図した挙動で、TreeView helper を通る partial render だけに効きます。

次を確認してください。

- `TreeView.configuration.render_log_level` の既定値は `:warn`
- row partial の wiring や render flow を追いたいときは `TreeView.configure { |config| config.render_log_level = :info }` または `:debug` を試す
- Rails の render log をそのまま見たいときは `TreeView.configure { |config| config.render_log_level = nil }` を使う
- `render_log_level` を変えても効かない場合は、host app の logger が `silence` に対応しているか確認する。対応していなければ TreeView は logger wrapper を使わず通常描画に戻る
- 足りない / 多すぎる log が controller、SQL、business log 側の話なら、TreeView ではなく host app の logger policy を調整する

次に読む文書:

- [Render log silencing](render-log-silencing.md)
- [使い方](usage.md)
- [Rendering Boundaries](rendering-boundaries.md)

## lazy loading で children が置き換わらない / remote state が戻らない

lazy loading は Turbo / server-driven 前提です。

次を確認してください。

- `UiConfig` に `load_children_path_builder` があるか
- `RenderState` に `lazy_loading: { enabled: true }` が入っているか
- host app endpoint が、自分で責任を持つ subtree または placeholder region を返しているか
- 一度読み込んだ row を次回 response で loaded として描画できるよう、host app 側で `loaded_keys` を維持しているか
- `build_client_side` と lazy loading を同時に使っていないか

loading や error の見た目だけは出るのに完了しない場合は、row partial より先に host app の request / response lifecycle を確認してください。

次に読む文書:

- [Lazy Loading](lazy-loading.md)
- [Children Pagination](children-pagination.md)
- [JavaScript event contract](js-events.md)

## selection payload が足りない / 想定と違う

selection checkbox の送信値は plain ID ではなく JSON string です。

次を確認してください。

- server side では `TreeView.parse_selection_params` で parse する
- JavaScript では checked かつ enabled な checkbox だけが対象になる
- JSON が壊れている値は selected payload array から除外され、`tree-view-selection:invalid-payload` で通知される
- cascade と indeterminate は、現在 DOM に描画されている row にだけ効く

次に読む文書:

- [Selection](selection.md)
- [JavaScript event contract](js-events.md)

## persisted state が保存・復元されない

persisted state は gem helper と host app policy の分担で成り立ちます。

次を確認してください。

- install generator を実行し、生成された model / migration を見直しているか
- 必要な owner model に generated concern を含めているか
- screen や tree placement ごとに安定した `tree_instance_key` を使っているか
- host app 側 save endpoint が owner を選び、authorization し、`StateStore` または `TreeView::PersistedStateController` を正しく呼んでいるか
- `RenderState` に explicit `expanded_keys` を渡している場合、それが persisted state より優先されることを理解しているか

次に読む文書:

- [Persisted State](persisted-state.md)
- [Tree diagnostics](tree-diagnostics.md)

## duplicate node key / orphan / DOM ID collision / cycle が出る

これはまず data shape または identifier の問題として見ます。

次を確認してください。

- tree 構築時に `validate_node_keys: true` を有効にする
- filter や permission scope が絡む dataset では `orphan_strategy:` を意図的に選ぶ
- development / test / pre-release check では `render_state.validate_unique_dom_ids!` を呼ぶ
- parent relationship に不正 loop が入りうる場合は `TreeView::CycleDiagnostics.new(tree).report` を使う

次に読む文書:

- [Tree diagnostics](tree-diagnostics.md)
- [Error hierarchy](errors.md)
- [Node keys](node-keys.md)

## 問題の本体が host app 側にあるとき

次の論点が絡む場合は、先に host app のコードを開いて確認してください。

- query や filtering policy
- authorization
- controller action や route
- Turbo Stream response shape
- selection や drag/drop の後に行う business action
- table design、caption、page layout

TreeView docs が責務境界を細かく書いているのは、gem を再利用可能なまま保つためです。

次に読む文書:

- [Rendering Boundaries](rendering-boundaries.md)
- [FAQ](faq.md)
- [設計思想と責務範囲](design-policy.md)
