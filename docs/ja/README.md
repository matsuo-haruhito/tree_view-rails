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
| [API判断ガイド](decision-guide.md) | use caseから適切なAPIやoptionを選ぶためのflowchartと対応表 |
| [Cookbook](cookbook.md) | よく使う構成例とAPIの組み合わせ方 |
| [Form と編集行](form-editing.md) | bulk edit form、inline editing layout、Form Object、row action、責務境界 |
| [API概要](api-overview.md) | 主要公開APIの概要 |
| [API仕様](api.md) | 主要オブジェクト、引数、挙動、制約 |
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
| [Accessibility Semantics](accessibility-semantics.md) | table-first accessibility semanticsとARIA配置方針 |
| [Drag and Drop](drag-and-drop.md) | row event payloadを使ったdrag-and-drop連携の境界 |
| [Children Pagination](children-pagination.md) | lazy loadingと組み合わせるserver-side children pagination方針 |

## 保守者向け

| ドキュメント | 内容 |
|---|---|
| [Public API](public-api.md) | host app が直接使ってよいAPIと互換性方針 |
| [Release checklist](release.md) | release前に確認するテスト、docs、gem package作業 |
| [設計思想と責務範囲](design-policy.md) | gemが担う責務、含めるもの、含めないもの、設計判断 |
| [開発・保守方針](development.md) | テスト、CI、ドキュメント更新、今後の作業 |
| [Code Quality](code-quality.md) | lint、test、error message、docs品質の方針 |

## 読む順番

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

やりたいuse caseは決まっているが、使うAPIに迷う場合は [API判断ガイド](decision-guide.md) から確認してください。

API全体の入口を確認したい場合は、まず [API概要](api-overview.md) を読み、細かい仕様は [API仕様](api.md) を参照してください。

具体的な組み合わせ例を見たい場合は [Cookbook](cookbook.md) を参照してください。編集寄りの row layout は [Form と編集行](form-editing.md) を参照してください。

TreeView固有の言葉や識別子設計で迷った場合は、[用語集](glossary.md)、[Node keys](node-keys.md)、[Tree diagnostics](tree-diagnostics.md) を参照してください。

accessibility semantics は [Accessibility Semantics](accessibility-semantics.md) を参照してください。

翻訳・日英対応の優先度を確認する場合は [Documentation i18n audit](../i18n-audit.md) を参照してください。
