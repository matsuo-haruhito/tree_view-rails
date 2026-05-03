# tree_view docs

`tree_view` の詳細ドキュメントです。

README は利用者向けの短い入口に留め、設計思想・導入手順・API仕様・開発方針はこの `docs/` 配下に分けて管理します。

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| [設計思想と責務範囲](design-policy.md) | gem が担う責務、含めるもの、含めないもの、設計判断 |
| [導入手順](installation.md) | Gemfile、CSS、importmap、Propshaft / Sprockets、開発環境 |
| [最小利用例](minimal-usage.md) | host app での controller、view、row partial の最小構成 |
| [使い方](usage.md) | 通常Tree、static表示、Turbo表示、RenderState、view実装例 |
| [Selection](selection.md) | checkbox selection、visibility、送信値 parse |
| [Public API](public-api.md) | host app が直接使ってよい API と互換性方針 |
| [API仕様](api.md) | 主要オブジェクト、引数、挙動、制約 |
| [Release checklist](release.md) | release 前に確認するテスト、docs、gem package 作業 |
| [開発・保守方針](development.md) | テスト、CI、ドキュメント更新、今後の作業 |

## 読む順番

初めて使う場合は [導入手順](installation.md)、[最小利用例](minimal-usage.md)、[使い方](usage.md) の順に確認してください。

selection checkbox を使う場合は [Selection](selection.md) を参照してください。

設計や拡張方針を確認したい場合は [設計思想と責務範囲](design-policy.md) を参照してください。

APIの細かい仕様や、実装時の判断に迷った場合は [API仕様](api.md) と [Public API](public-api.md) を参照してください。

release 作業前には [Release checklist](release.md) を確認してください。
