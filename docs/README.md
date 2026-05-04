# tree_view docs

`tree_view` の詳細ドキュメントです。

README は利用者向けの短い入口に留め、設計思想・導入手順・API仕様・開発方針はこの `docs/` 配下に分けて管理します。

## 利用者向け

TreeViewをhost Rails appに組み込む人は、まず以下を確認してください。

| ドキュメント | 内容 |
|---|---|
| [導入手順](installation.md) | Gemfile、CSS、importmap、Propshaft / Sprockets、開発環境 |
| [最小利用例](minimal-usage.md) | host app での controller、view、row partial の最小構成 |
| [使い方](usage.md) | 通常Tree、static表示、Turbo表示、RenderState、view実装例 |
| [Cookbook](cookbook.md) | 既存APIを組み合わせた代表的な利用パターン |
| [用語集](glossary.md) | TreeView固有の概念、コード上の表現、責務の整理 |
| [Selection](selection.md) | checkbox selection、visibility、送信値 parse |
| [Breadcrumb helper](breadcrumb.md) | 現在nodeや任意nodeの親階層pathをパンくずとして描画するhelper |
| [Depth labels](depth-labels.md) | node depthを任意のラベルとして表示するhook |
| [Row status](row-status.md) | 行全体のdisabled / readonly状態を表すhook |
| [Node keys](node-keys.md) | 異種nodeや複数TreeViewで衝突しにくいnode_key生成helper |
| [Tree diagnostics helpers](tree-diagnostics.md) | expanded keys、統計、orphan診断などの構造確認API |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むための hook と data 属性 |
| [API仕様](api.md) | 主要オブジェクト、引数、挙動、制約 |

## 保守者向け

TreeView gem自体を変更・releaseする人は、以下も確認してください。

| ドキュメント | 内容 |
|---|---|
| [設計思想と責務範囲](design-policy.md) | gem が担う責務、含めるもの、含めないもの、設計判断 |
| [Rendering boundaries](rendering-boundaries.md) | Rails helper / ERB による描画境界と host app 側の責務 |
| [Persisted State](persisted-state.md) | 開閉状態の保存/復元に関する設計方針 |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むための設計方針 |
| [Static HTML mock](mockups/default-tree.html) | gem標準の DOM 構造と CSS 適用状態を確認する静的モック |
| [Public API](public-api.md) | host app が直接使ってよい API と互換性方針 |
| [Release checklist](release.md) | release 前に確認するテスト、docs、gem package 作業 |
| [開発・保守方針](development.md) | テスト、CI、ドキュメント更新、今後の作業 |

## 読む順番

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

既存APIの組み合わせ方を確認したい場合は [Cookbook](cookbook.md) を参照してください。

TreeView固有の用語や、コード上の名前との対応を確認したい場合は [用語集](glossary.md) を参照してください。

selection checkbox を使う場合は [Selection](selection.md) を参照してください。

描画時のRails helper / ERB境界を確認したい場合は [Rendering boundaries](rendering-boundaries.md) を参照してください。

現在nodeの親階層pathをパンくずとして表示したい場合は [Breadcrumb helper](breadcrumb.md) を参照してください。

node depthを画面上にラベル表示したい場合は [Depth labels](depth-labels.md) を参照してください。

行全体をdisabled / readonlyとして表示したい場合は [Row status](row-status.md) を参照してください。

異種nodeや複数TreeViewでnode_key衝突を避けたい場合は [Node keys](node-keys.md) を参照してください。

検索結果の初期展開、ツリー規模の確認、不正な親IDの調査を行う場合は [Tree diagnostics helpers](tree-diagnostics.md) を参照してください。

設計や拡張方針を確認したい場合は [設計思想と責務範囲](design-policy.md) を参照してください。

開閉状態の保存/復元を検討する場合は [Persisted State](persisted-state.md) を参照してください。

子ノードの追加読み込みを行う場合は [Lazy Loading](lazy-loading.md) を参照してください。

APIの細かい仕様や、実装時の判断に迷った場合は [API仕様](api.md) と [Public API](public-api.md) を参照してください。

release 作業前には [Release checklist](release.md) を確認してください。
