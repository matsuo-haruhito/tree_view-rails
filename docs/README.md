# tree_view docs

`tree_view` の詳細ドキュメントです。

README は利用者向けの短い入口に留め、設計思想・導入手順・API仕様・開発方針はこの `docs/` 配下に分けて管理します。

This directory contains detailed `tree_view` documentation.

The top-level README stays as a short user-facing entry point. Design policy, installation details, API references, and maintenance guidance live under `docs/`.

## ドキュメントの言語対応 / Documentation language status

`0.1.0` リリース前に、ドキュメントの日英対応状況を明示的に管理します。

Before the `0.1.0` release, documentation language coverage is tracked explicitly.

- [Documentation i18n audit](i18n-audit.md): 各ドキュメントの言語状態、優先度、翻訳方針 / language status, priority, and translation policy for each document

現時点では、すべてのドキュメントが完全な日英併記になっているわけではありません。利用者向けの入口、導入、最小利用例、使い方、API仕様から優先的に日英対応を進めます。

Not every document is fully bilingual yet. Bilingual coverage is prioritized for user-facing entry points, installation, minimal usage, usage, and API references first.

## 利用者向け / For users

TreeViewをhost Rails appに組み込む人は、まず以下を確認してください。

If you are integrating TreeView into a host Rails app, start with these documents.

| ドキュメント / Document | 内容 / Description |
|---|---|
| [導入手順 / Installation](installation.md) | Gemfile、CSS、importmap、Propshaft / Sprockets、開発環境 / Gemfile, CSS, importmap, Propshaft / Sprockets, and development setup |
| [最小利用例 / Minimal usage](minimal-usage.md) | host app での controller、view、row partial の最小構成 / Minimal controller, view, and row partial setup in a host app |
| [使い方 / Usage](usage.md) | 通常Tree、static表示、Turbo表示、RenderState、view実装例 / Tree basics, static rendering, Turbo rendering, RenderState, and view examples |
| [API概要 / API overview](api-overview.md) | 主要公開APIの概要 / Bilingual overview of the main public APIs |
| [Cookbook](cookbook.md) | 既存APIを組み合わせた代表的な利用パターン / Common patterns composed from existing APIs |
| [用語集 / Glossary](glossary.md) | TreeView固有の概念、コード上の表現、責務の整理 / TreeView concepts, code names, and responsibility boundaries |
| [Selection](selection.md) | checkbox selection、visibility、送信値 parse / checkbox selection, visibility, and submitted value parsing |
| [Breadcrumb helper](breadcrumb.md) | 現在nodeや任意nodeの親階層pathをパンくずとして描画するhelper / Helper for rendering ancestor paths as breadcrumbs |
| [Depth labels](depth-labels.md) | node depthを任意のラベルとして表示するhook / Hook for displaying node depth labels |
| [Row status](row-status.md) | 行全体のdisabled / readonly状態を表すhook / Hook for disabled / readonly row state |
| [Node keys](node-keys.md) | 異種nodeや複数TreeViewで衝突しにくいnode_key生成helper / node_key helper for avoiding collisions across heterogeneous nodes or multiple TreeViews |
| [Tree diagnostics helpers](tree-diagnostics.md) | expanded keys、統計、orphan診断などの構造確認API / Structure inspection APIs for expanded keys, stats, and orphan diagnostics |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むための hook と data 属性 / Hooks and data attributes for loading children on demand |
| [Windowed Rendering](windowed-rendering.md) | 表示対象行をoffset / limitで一部だけ描画する opt-in API / Opt-in API for rendering visible rows by offset / limit |
| [API仕様 / API reference](api.md) | 主要オブジェクト、引数、挙動、制約 / Main objects, arguments, behavior, and constraints |

## 保守者向け / For maintainers

TreeView gem自体を変更・releaseする人は、以下も確認してください。

If you are changing or releasing the TreeView gem itself, also read these documents.

| ドキュメント / Document | 内容 / Description |
|---|---|
| [設計思想と責務範囲 / Design policy](design-policy.md) | gem が担う責務、含めるもの、含めないもの、設計判断 / Gem responsibilities, included scope, excluded scope, and design decisions |
| [Rendering boundaries](rendering-boundaries.md) | Rails helper / ERB による描画境界と host app 側の責務 / Rendering boundaries between Rails helpers, ERB, and host app responsibilities |
| [Persisted State](persisted-state.md) | 開閉状態の保存/復元に関する設計方針 / Design policy for saving and restoring expansion state |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むための設計方針 / Design policy for loading child nodes on demand |
| [Windowed Rendering](windowed-rendering.md) | RenderWindow と opt-in windowed rendering の設計方針 / Design policy for RenderWindow and opt-in windowed rendering |
| [Static HTML mock](mockups/default-tree.html) | gem標準の DOM 構造と CSS 適用状態を確認する静的モック / Static mock for checking the default DOM and CSS state |
| [Public API](public-api.md) | host app が直接使ってよい API と互換性方針 / APIs host apps may use directly and compatibility policy |
| [Release checklist](release.md) | release 前に確認するテスト、docs、gem package 作業 / Release tests, documentation, and gem package checklist |
| [開発・保守方針 / Development](development.md) | テスト、CI、ドキュメント更新、今後の作業 / Tests, CI, documentation updates, and future work |
| [Documentation i18n audit](i18n-audit.md) | 日英対応状況、翻訳優先度、翻訳方針 / Language status, translation priority, and translation policy |

## 読む順番 / Reading order

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

For first-time usage, read [Installation](installation.md), [Minimal usage](minimal-usage.md), and [Usage](usage.md) in that order.

API全体の入口を確認したい場合は、まず [API概要](api-overview.md) を読み、細かい仕様は [API仕様](api.md) を参照してください。

For a high-level API entry point, read [API overview](api-overview.md) first, then use [API reference](api.md) for details.

既存APIの組み合わせ方を確認したい場合は [Cookbook](cookbook.md) を参照してください。

For common combinations of existing APIs, see [Cookbook](cookbook.md).

TreeView固有の用語や、コード上の名前との対応を確認したい場合は [用語集](glossary.md) を参照してください。

For TreeView-specific terms and their code names, see [Glossary](glossary.md).

selection checkbox を使う場合は [Selection](selection.md) を参照してください。

For checkbox selection, see [Selection](selection.md).

描画時のRails helper / ERB境界を確認したい場合は [Rendering boundaries](rendering-boundaries.md) を参照してください。

For Rails helper / ERB rendering boundaries, see [Rendering boundaries](rendering-boundaries.md).

現在nodeの親階層pathをパンくずとして表示したい場合は [Breadcrumb helper](breadcrumb.md) を参照してください。

For breadcrumbs from an item's ancestor path, see [Breadcrumb helper](breadcrumb.md).

node depthを画面上にラベル表示したい場合は [Depth labels](depth-labels.md) を参照してください。

For displaying node depth labels, see [Depth labels](depth-labels.md).

行全体をdisabled / readonlyとして表示したい場合は [Row status](row-status.md) を参照してください。

For disabled / readonly row states, see [Row status](row-status.md).

異種nodeや複数TreeViewでnode_key衝突を避けたい場合は [Node keys](node-keys.md) を参照してください。

For avoiding node_key collisions across heterogeneous nodes or multiple TreeViews, see [Node keys](node-keys.md).

検索結果の初期展開、ツリー規模の確認、不正な親IDの調査を行う場合は [Tree diagnostics helpers](tree-diagnostics.md) を参照してください。

For initial expansion from search results, tree size inspection, or invalid parent ID diagnostics, see [Tree diagnostics helpers](tree-diagnostics.md).

設計や拡張方針を確認したい場合は [設計思想と責務範囲](design-policy.md) を参照してください。

For design and extension policy, see [Design policy](design-policy.md).

開閉状態の保存/復元を検討する場合は [Persisted State](persisted-state.md) を参照してください。

For saving and restoring expansion state, see [Persisted State](persisted-state.md).

子ノードの追加読み込みを行う場合は [Lazy Loading](lazy-loading.md) を参照してください。

For loading child nodes on demand, see [Lazy Loading](lazy-loading.md).

大量ノードで一部の表示行だけを描画したい場合は [Windowed Rendering](windowed-rendering.md) を参照してください。

For rendering only a window of visible rows in large trees, see [Windowed Rendering](windowed-rendering.md).

APIの細かい仕様や、実装時の判断に迷った場合は [API仕様](api.md) と [Public API](public-api.md) を参照してください。

For detailed API behavior and implementation decisions, see [API reference](api.md) and [Public API](public-api.md).

release 作業前には [Release checklist](release.md) を確認してください。

Before release work, see [Release checklist](release.md).

翻訳・日英対応の優先度を確認する場合は [Documentation i18n audit](i18n-audit.md) を参照してください。

For translation priority and bilingual readiness, see [Documentation i18n audit](i18n-audit.md).
