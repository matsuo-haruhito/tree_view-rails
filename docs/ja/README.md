# tree_view ドキュメント

`tree_view` の日本語ドキュメントです。

README は利用者向けの短い入口に留め、設計思想・導入手順・API仕様・開発方針はこの `docs/` 配下に分けて管理します。

## ドキュメントの言語対応

`docs/` は言語別ディレクトリで管理しており、`0.1.0` リリース後も日英対応状況を継続的に確認します。

- [Documentation i18n audit](../i18n-audit.md): 各ドキュメントの言語状態、優先度、翻訳方針
- [English documentation](../en/README.md)

## 利用者向け

TreeView を host Rails app に組み込む人は、まず以下を確認してください。

| ドキュメント | 内容 |
|---|---|
| [導入手順](installation.md) | Gemfile、CSS、importmap、Propshaft / Sprockets、開発環境 |
| [最小利用例](minimal-usage.md) | host app での controller、view、row partial の最小構成 |
| [使い方](usage.md) | 通常 Tree、static 表示、Turbo 表示、RenderState、view 実装例 |
| [Turbo Frame オプション](turbo-frame.md) | 追加 JavaScript なしで TreeView の Turbo toggle link を host app の Turbo Frame に向ける設定 |
| [ローカライズされた名前](localized-names.md) | ActiveModel / I18n 経由で model、attribute、node type の表示名を解決する helper |
| [API判断ガイド](decision-guide.md) | use case から適切な API や option を選ぶための flowchart と対応表 |
| [FAQ](faq.md) | 責務境界、query 量への期待、よくある誤解を短く確認するための入口 |
| [トラブルシューティング](troubleshooting.md) | 困っている症状から関連 docs を逆引きする入口 |
| [視覚リファレンス mockup](../mockups/README.md) | Rails app を起動せずに baseline output と interaction state を確認する static HTML/CSS リファレンスです。最初の俯瞰には [review-gallery.html](../mockups/review-gallery.html) を使い、baseline DOM 構造と shared CSS reference を直接見たいときは [default-tree.html](../mockups/default-tree.html) を開き、その後は mockup index で focused pages と各 page の役割を確認してください。 |
| [アクセシビリティセマンティクス](accessibility-semantics.md) | table-first rows、ARIA 配置、keyboard boundary、host app responsibility の first-class accessibility guidance |
| [Cookbook](cookbook.md) | よく使う構成例と API の組み合わせ方 |
| [NodePresenter row partial パターン](node-presenter-row-partials.md) | app 固有の Column / Action DSL を増やさず、row partial から NodePresenter を使う pattern |
| [Form と編集行](form-editing.md) | bulk edit form、inline editing layout、Form Object、row action、責務境界 |
| [Resource table bridge](resource-table-bridge.md) | 別 table layer が列推論や table state を持つ場合に TreeView 側で階層行だけを描画する bridge |
| [API 概要](api-overview.md) | 主要公開 API の概要 |
| [API 仕様](api.md) | 主要オブジェクト、引数、挙動、制約 |
| [PathTreeBuilder](path-tree-builder.md) | path らしい record 値から生成 folder node と record node を作る API |
| [エラー階層](errors.md) | 公開 TreeView error class と rescue 方針 |
| [JavaScript イベント契約](js-events.md) | 公開 Stimulus event name、detail payload、互換性方針 |
| [移行ガイド](migration.md) | upgrade 時の互換性、deprecation、rename、release note の見方 |
| [render log レベル](render-log-level.md) | host app log に出る TreeView partial render log の抑制設定 |
| [用語集](glossary.md) | TreeView docs とコードで使う主要用語 |
| [Node key 設計](node-keys.md) | node_key の設計、衝突回避、validation |
| [Tree diagnostics](tree-diagnostics.md) | node_key、DOM ID、orphan、cycle などの構造確認 API |
| [Selection](selection.md) | checkbox selection、visibility、送信値 parse |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むための hook と data 属性 |
| [Windowed Rendering](windowed-rendering.md) | 表示対象行を offset / limit で一部だけ描画する opt-in API |
| [Persisted State](persisted-state.md) | 開閉状態の保存 / 復元と generator |
| [Breadcrumb](breadcrumb.md) | 現在 node や任意 node の親階層 path をパンくずとして描画する helper |
| [Depth Labels](depth-labels.md) | node depth を任意のラベルとして表示する hook |
| [Row Status](row-status.md) | 行全体の disabled / readonly 状態を表す hook |
| [Filtered Trees](filtered-trees.md) | 検索・絞り込み結果を tree として表示するための API |
| [描画責務の境界](rendering-boundaries.md) | TreeView gem と host app の描画責務境界 |
| [描画スケール](render-scale.md) | 大きな tree の描画量を抑えるための方針 |
| [Host App 拡張ポイント](host-app-extension-points.md) | host app 側で拡張・統合するための hook 一覧 |
| [公開名の判断メモ](public-name-decisions.md) | 誤解しやすい公開 builder 名に関する判断 |
| [Drag and Drop](drag-and-drop.md) | row event payload を使った drag-and-drop 連携の境界 |
| [Children Pagination](children-pagination.md) | lazy loading と組み合わせる server-side children pagination 方針 |

## 保守者向け

| ドキュメント | 内容 |
|---|---|
| [Product Profile](../../Product%20Profile.md) | repository の位置づけ、source-of-truth の順序、保守境界、non-goals |
| [AGENTS.md](../../AGENTS.md) | repository 固有の maintainer workflow、最初に読む順序、docs 更新ルール |
| [root docs index](../README.md) | cross-language docs map と、durable maintainer docs の maintenance entry point |
| [CHANGELOG.md](../../CHANGELOG.md) | public change、互換性メモ、重要な docs 追加を release 観点で追うための要約 |
| [Documentation i18n audit](../i18n-audit.md) | 日英同期ルール、technical asset inventory、翻訳優先度の確認表 |
| [公開 API](public-api.md) | host app が直接使ってよい API と互換性方針 |
| [移行ガイド](migration.md) | 互換性の約束、deprecation、release note 期待値を upgrade 観点で整理したガイド |
| [リリースチェックリスト](release.md) | release 前に確認する test、docs、gem package 作業 |
| [設計思想と責務範囲](design-policy.md) | gem が担う責務、含めるもの、含めないもの、設計判断 |
| [開発・保守方針](development.md) | test、CI、ドキュメント更新、今後の作業 |
| [コード品質](code-quality.md) | lint、test、error message、docs 品質の方針 |

## 読む順番

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

やりたい使い方は決まっているが、使う API に迷う場合は [API判断ガイド](decision-guide.md) から確認してください。

API を選ぶ前に責務境界やよくある誤解を短く確認したい場合は [FAQ](faq.md) を参照してください。

困っている症状から最短で関連文書へ行きたい場合は [トラブルシューティング](troubleshooting.md) を参照してください。

baseline の DOM 構造や interaction state を静的に確認したい場合は [視覚リファレンス mockup](../mockups/README.md) を参照してください。最初は [review-gallery.html](../mockups/review-gallery.html) から俯瞰し、baseline DOM 構造と shared CSS reference を直接見たいときは [default-tree.html](../mockups/default-tree.html) を開き、その後は mockup index で focused pages と各 page の役割を確認してください。

API 全体の入口を確認したい場合は、まず [API 概要](api-overview.md) を読み、細かい仕様は [API 仕様](api.md) を参照してください。

TreeView toggle link を Turbo Frame に向けたい場合は [Turbo Frame オプション](turbo-frame.md) を参照してください。

locale に沿った model、attribute、node type の表示名解決は [ローカライズされた名前](localized-names.md) を参照してください。

path らしい record 値から生成 folder tree を作りたい場合は [PathTreeBuilder](path-tree-builder.md) を参照してください。

通常 table と tree table で同じ列定義や table state を共有したい場合は [Resource table bridge](resource-table-bridge.md) を参照してください。

具体的な組み合わせ例を見たい場合は [Cookbook](cookbook.md) を参照してください。NodePresenter と row partial の組み合わせは [NodePresenter row partial パターン](node-presenter-row-partials.md) を参照してください。編集寄りの row layout は [Form と編集行](form-editing.md) を参照してください。

TreeView 固有の言葉や識別子設計で迷った場合は、[用語集](glossary.md)、[Node key 設計](node-keys.md)、[Tree diagnostics](tree-diagnostics.md) を参照してください。

TreeView 固有 error の rescue 方針は [エラー階層](errors.md) を参照してください。

公開 Stimulus event name と payload は [JavaScript イベント契約](js-events.md) を参照してください。

upgrade 判断、deprecation、release note の見方は [移行ガイド](migration.md) を参照してください。

アクセシビリティセマンティクス、ARIA 配置、keyboard boundary は [アクセシビリティセマンティクス](accessibility-semantics.md) を参照してください。

host app log 上の TreeView render log の出力を調整したい場合は [render log レベル](render-log-level.md) を参照してください。

翻訳・日英対応の優先度を確認する場合は [Documentation i18n audit](../i18n-audit.md) を参照してください。