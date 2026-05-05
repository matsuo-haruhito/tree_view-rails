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
| [API概要](api-overview.md) | 主要公開APIの概要 |
| [API仕様](../api.md) | 主要オブジェクト、引数、挙動、制約 |
| [Selection](selection.md) | checkbox selection、visibility、送信値parse |
| [Lazy Loading](lazy-loading.md) | 子ノードを必要なタイミングで読み込むためのhookとdata属性 |
| [Windowed Rendering](windowed-rendering.md) | 表示対象行をoffset / limitで一部だけ描画するopt-in API |
| [Persisted State](persisted-state.md) | 開閉状態の保存/復元とgenerator |
| [Breadcrumb](breadcrumb.md) | 現在nodeや任意nodeの親階層pathをパンくずとして描画するhelper |

## 保守者向け

| ドキュメント | 内容 |
|---|---|
| [Public API](../public-api.md) | host app が直接使ってよいAPIと互換性方針 |
| [Release checklist](../release.md) | release前に確認するテスト、docs、gem package作業 |
| [設計思想と責務範囲](../design-policy.md) | gemが担う責務、含めるもの、含めないもの、設計判断 |
| [開発・保守方針](../development.md) | テスト、CI、ドキュメント更新、今後の作業 |

## 読む順番

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

API全体の入口を確認したい場合は、まず [API概要](api-overview.md) を読み、細かい仕様は [API仕様](../api.md) を参照してください。

翻訳・日英対応の優先度を確認する場合は [Documentation i18n audit](../i18n-audit.md) を参照してください。
