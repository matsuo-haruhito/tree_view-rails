# TreeView Context

## 目的

このリポジトリは `tree_view` gem 本体専用のリポジトリです。

Rails 7以降のhost appから使える、親子データ表示用のツリー基盤を提供します。

詳細な仕様・設計思想・導入手順は `docs/` に分離しています。

## 最初に読むドキュメント

- 利用者向け概要: [README.md](README.md)
- ドキュメント一覧: [docs/README.md](docs/README.md)
- 設計思想と責務範囲: [docs/design-policy.md](docs/design-policy.md)
- API仕様: [docs/api.md](docs/api.md)
- 開発・保守方針: [docs/development.md](docs/development.md)

## 基本方針

- `TreeView` コアは木構造ロジックと描画統合の薄い入口に寄せる
- host app 固有のroute名、文言、Turbo Stream更新、CRUDはこのrepoに含めない
- `UiConfig` / `UiConfigBuilder` はgenericなbuilderに留める
- row partial差し替えを公開拡張ポイントとして維持する
- host appがstatic表示だけで使えるように、Turbo開閉前提を必須にしない

## 主要な公開API

- `TreeView::Tree`
- `TreeView::Traversal`
- `TreeView::GraphAdapter`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeViewHelper`

詳細は [docs/api.md](docs/api.md) を参照してください。

## 現在の作業メモ

- [ ] 外部host appからinstallして動作確認する
- [x] importmap / asset 読み込み手順を整理する
- [x] static tree 用のAPI / partialを追加する
- [x] gemに無関係なsample app view残骸を取り除く
- [x] container上で `bundle exec rspec` を回せる最小Docker構成を追加する
- [x] 必要ならdummy appかintegration specを追加する
- [x] GitHub Actionsで `bundle exec rake` を実行する
- [x] READMEをユーザー向け入口に整理し、詳細を `docs/` に分離する

## AI / 開発者向け注意

このファイルは詳細仕様書ではありません。

長い仕様や設計判断を追う場合は、`docs/` 配下を参照してください。

機能や公開APIを変更した場合は、READMEだけでなく、該当する `docs/` も更新してください。
