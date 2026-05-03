# tree_view docs

`tree_view` の詳細ドキュメントです。

README は利用者向けの短い入口に留め、設計思想・導入手順・API仕様・開発方針はこの `docs/` 配下に分けて管理します。

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| [設計思想と責務範囲](design-policy.md) | gem が担う責務、含めるもの、含めないもの、設計判断 |
| [導入手順](installation.md) | Gemfile、CSS、importmap、Propshaft / Sprockets、開発環境 |
| [使い方](usage.md) | 通常Tree、static表示、Turbo表示、RenderState、view実装例 |
| [API仕様](api.md) | 公開API、主要オブジェクト、引数、挙動、制約 |
| [開発・保守方針](development.md) | テスト、CI、ドキュメント更新、今後の作業 |

## 読む順番

利用者はまず [導入手順](installation.md) と [使い方](usage.md) を読めば十分です。

設計や拡張方針を確認したい場合は [設計思想と責務範囲](design-policy.md) を参照してください。

APIの細かい仕様や、実装時の判断に迷った場合は [API仕様](api.md) を参照してください。
