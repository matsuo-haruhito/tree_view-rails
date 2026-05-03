# 開発・保守方針

## 基本方針

`tree_view` は Rails アプリで再利用できるツリー表示基盤として保守します。

host app 固有の業務処理やCRUDは持ち込まず、複数アプリで使える表示・構造化・描画統合の機能に絞ります。

## 開発時の確認

```bash
bundle install
bundle exec rspec
bundle exec rake build
```

`Rakefile` の default task は spec 実行です。

```bash
bundle exec rake
```

## CI

GitHub Actions では、`main` へのpushとPull Requestで `bundle exec rake` を実行します。

CIはまず最小構成とし、必要に応じて以下を追加します。

- Ruby version matrix
- RuboCop
- Rails version matrix
- build確認

## Docker / Dev Container

ローカルRubyを入れずに確認したい場合はDockerを使えます。

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app bundle exec rspec
docker compose run --rm app bundle exec rake build
```

VS Code Dev Containersを使う場合は `.devcontainer/devcontainer.json` を利用できます。

## ドキュメント更新ルール

機能や公開APIを変更した場合は、必要に応じて以下を更新します。

- `README.md`
  - 利用者向けの短い概要と導線
- `docs/installation.md`
  - 導入手順が変わった場合
- `docs/usage.md`
  - 使い方やサンプルが変わった場合
- `docs/api.md`
  - 公開API、引数、戻り値、制約が変わった場合
- `docs/design-policy.md`
  - 責務範囲や設計判断が変わった場合
- `context.md`
  - AI/開発者向けの短い入口や現在の作業状況が変わった場合

## context.md の位置づけ

`context.md` は詳細仕様書ではなく、AIや開発者が最初に読むための軽量な文脈ファイルです。

詳細は `docs/` に分けます。

## Issue化している主な拡張候補

今後の主な機能追加候補はGitHub Issuesで管理します。

- 子ノード起点で親階層を補完した通常向きTree
- 親方向へ辿る逆向きTreeView
- orphan node handling
- ノード単位の初期展開状態
- row class / data属性 builder
- 最大表示階層制限
- node_key / DOM ID 衝突検出
- RenderStateを直接描画できるhelper
- sorter戻り値検証

## 互換性

公開APIを変更する場合は、既存の利用例が壊れないようにします。

破壊的変更が必要な場合は、README / docs / changelog相当の場所に明記します。
