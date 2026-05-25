# tree_view ドキュメント

`tree_view` の日本語ドキュメントです。

README は利用者向けの短い入口に留め、設計思想・導入手順・API仕様・開発方針はこの `docs/` 配下に分けて管理します。

## ドキュメントの言語対応

`0.1.0` リリース前に、ドキュメントの日英対応状況を明示的に管理します。

- [Documentation i18n audit](../i18n-audit.md): 各ドキュメントの言語状態、優先度、翻訳方針
- [English documentation](../en/README.md)

## 利用者向け

TreeViewをhost Rails appに組み込む人は、まず以下を確認してください。

| ドキュメント | 内容 |
|---|---|
| [導入手順](installation.md) | Gemfile、CSS、importmap、Propshaft / Sprockets、開発環境 |
| [最小利用例](minimal-usage.md) | host app での controller、view、row partial の最小構成 |
| [使い方](usage.md) | 通常Tree、static表示、Turbo表示、RenderState、view実装例 |
| [Turbo Frame option](turbo-frame.md) | 追加JavaScriptなしで TreeView の Turbo toggle link を host app の Turbo Frame に向ける設定 |
| [Localized names](localized-names.md) | ActiveModel / I18n 経由で model、attribute、node type の表示名を解決するhelper |
| [API判断ガイド](decision-guide.md) | use caseから適切なAPIやoptionを選ぶためのflowchartと対応表 |
| [FAQ](faq.md) | 責務境界、query 量への期待、よくある誤解を短く確認するための入口 |
| [Troubleshooting](troubleshooting.md) | 困っている症状から関連 docs を逆引きする入口 |
| [Visual reference mockups](../mockups/README.md) | Rails app を起動せずに baseline output と interaction state を確認する static HTML/CSS リファレンス |
| [Accessibility Semantics](accessibility-semantics.md) | table-first rows、ARIA配置、keyboard boundary、host app responsibility の first-class accessibility guidance |
| [Cookbook](cookbook.md) | よく使う構成例とAPIの組み合わせ方 |
| [NodePresenter row partial patterns](node-presenter-row-partials.md) | app固有の Column / Action DSL を増やさず、row partial から NodePresenter を使うpattern |
| [Form と編集行](form-editing.md) | bulk edit form、inline editing layout、Form Object、row action、責務境界 |
| [Resource table bridge](resource-table-bridge.md) | 別table layerが列推論やtable stateを持つ場合にTreeView側で階層行だけを描画するbridge |
| [API概要](api-overview.md) | 主要公開APIの概要 |
| [API仕様](api.md) | 主要オブジェクト、引数、挙動、制約 |
| [PathTreeBuilder](path-tree-builder.md) | path らしい record 値から生成folder nodeとrecord nodeを作るAPI |
| [Error hierarchy](errors.md) | 公開 TreeView error class と rescue 方針 |
| [JavaScript event contract](js-events.md) | 公開 Stimulus event name、detail payload、互換性方針 |
| [render log level](render-log-level.md) | host app log に出る TreeView partial render log の抑制設定 |
| [用語集](glossary.md) | TreeView docsとコードで使う主要用語 |
| [Node keys](node-keys.md) | node_keyの設計、衝突回避、validation |
| [Tree diagnostics](tree-diagnostics.md) | node_key、DOM ID、orphan、cycleなどの構造確認API |
| [Selection](selection.md) | checkbox selection、visibility、送信値parse |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むためのhookとdata属性 |
| [Windowed Rendering](windowed-rendering.md) | 表示対象行をoffset / limitで一部だけ描画するopt-in API |
| [Persisted State](persisted-state.md) | 開閉状態の保存/復元とgenerator |
| [Breadcrumb](breadcrumb.md) | 現在nodeや任意nodeの親階層pathをパンくずとして描画するhelper |
| [Depth Labels](depth-labels.md) | node depthを任意のラベルとして表示するhook |
| [Row Status](row-status.md) | 行全体のdisabled / readonly状態を表すhook |
| [Filtered Trees](filtered-trees.md) | 検索・絞り込み結果をtreeとして表示するためのAPI |
| [Rendering Boundaries](rendering-boundaries.md) | TreeView gem とhost appの描画責務境界 |
| [Render Scale](render-scale.md) | 大きなtreeの描画量を抑えるための方針 |
| [Host App Extension Points](host-app-extension-points.md) | host app側で拡張・統合するためのhook一覧 |
| [Public Name Decisions](public-name-decisions.md) | 誤解しやすい公開builder名に関する判断 |
| [Drag and Drop](drag-and-drop.md) | row event payloadを使ったdrag-and-drop連携の境界 |
| [Children Pagination](children-pagination.md) | lazy loadingと組み合わせるserver-side children pagination方針 |

## 保守者向け

| ドキュメント | 内容 |
|---|---|
| [Product Profile](../../Product%20Profile.md) | repository の位置づけ、source-of-truth の順序、保守境界、non-goals |
| [Public API](public-api.md) | host app が直接使ってよいAPIと互換性方針 |
| [Release checklist](release.md) | release前に確認するテスト、docs、gem package作業 |
| [設計思想と責務範囲](design-policy.md) | gemが担う責務、含めるもの、含めないもの、設計判断 |
| [開発・保守方針](development.md) | テスト、CI、ドキュメント更新、今後の作業 |
| [Code Quality](code-quality.md) | lint、test、error message、docs品質の方針 |

## 読む順番

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

やりたいuse caseは決まっているが、使うAPIに迷う場合は [API判断ガイド](decision-guide.md) から確認してください。

APIを選ぶ前に責務境界やよくある誤解を短く確認したい場合は [FAQ](faq.md) を参照してください。

困っている症状から最短で関連文書へ行きたい場合は [Troubleshooting](troubleshooting.md) を参照してください。

baseline の DOM 構造や interaction state を静的に確認したい場合は [Visual reference mockups](../mockups/README.md) を参照してください。

API全体の入口を確認したい場合は、まず [API概要](api-overview.md) を読み、細かい仕様は [API仕様](api.md) を参照してください。

TreeView toggle link を Turbo Frame に向けたい場合は [Turbo Frame option](turbo-frame.md) を参照してください。

localeに沿った model、attribute、node type の表示名解決は [Localized names](localized-names.md) を参照してください。

path らしい record 値から生成folder treeを作りたい場合は [PathTreeBuilder](path-tree-builder.md) を参照してください。

通常tableとtree tableで同じ列定義やtable stateを共有したい場合は [Resource table bridge](resource-table-bridge.md) を参照してください。

具体的な組み合わせ例を見たい場合は [Cookbook](cookbook.md) を参照してください。NodePresenter と row partial の組み合わせは [NodePresenter row partial patterns](node-presenter-row-partials.md) を参照してください。編集寄りの row layout は [Form と編集行](form-editing.md) を参照してください。

TreeView固有の言葉や識別子設計で迷った場合は、[用語集](glossary.md)、[Node keys](node-keys.md)、[Tree diagnostics](tree-diagnostics.md) を参照してください。

TreeView 固有 error の rescue 方針は [Error hierarchy](errors.md) を参照してください。

公開 Stimulus event name とpayloadは [JavaScript event contract](js-events.md) を参照してください。

accessibility semantics、ARIA配置、keyboard boundary は [Accessibility Semantics](accessibility-semantics.md) を参照してください。

host app log 上の TreeView render log の出力を調整したい場合は [render log level](render-log-level.md) を参照してください。

翻訳・日英対応の優先度を確認する場合は [Documentation i18n audit](../i18n-audit.md) を参照してください。