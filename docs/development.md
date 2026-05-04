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

## Rails統合確認とデモアプリの役割

`tree_view-rails` 本体では、gemとして壊れていないことを確認するための軽量な統合specを持ちます。

本体側で確認する範囲は以下に留めます。

- `TreeView::Engine` initializer が helper / assets / importmap hook を登録できること
- host app view path 上の partial と `tree_view/tree_row` が組み合わせて描画できること
- `TreeView::Tree` / `TreeView::GraphAdapter` を使った代表的な描画が壊れていないこと
- Turbo用 path builder が最低限呼び出せること

一方、実画面に近い検証・見た目確認・playground 的な利用は `matsuo-haruhito/tree_view-rails-demo` に寄せます。

`tree_view-rails-demo` は以下の用途で使います。

- 最新の `tree_view-rails` に追従した実Rails appとしての動作確認
- 自己参照モデル、異種ノードGraphAdapter、Turbo Stream開閉などのサンプル拡充
- 将来的に公開playgroundとして使う可能性のある画面確認

ローカルでgem本体とdemo appを組み合わせて確認する場合は、demo app側で `TREE_VIEW_PATH` を指定します。

```bash
cd ../tree_view-rails-demo
TREE_VIEW_PATH=../tree_view-rails bundle install
TREE_VIEW_PATH=../tree_view-rails bin/rails db:setup
TREE_VIEW_PATH=../tree_view-rails bin/rails server
```

本体リポジトリに重い `spec/dummy` app は原則として持ちません。必要になった場合も、demo app と役割が重複しない最小構成に留めます。

## Betaリリース前の整理方針

現時点では後方互換性よりも、beta版として公開する前にAPIと内部設計を綺麗に整えることを優先します。

beta版リリース前に以下を行います。

- open issue をすべて整理・対応する
- 追加でやるべきことがないか全体確認する
- コード全体を見直し、責務分離・命名・テスト構成をリファクタリングする
- `tree_view-rails-demo` を最新版に合わせて拡充する

beta版以降は、破壊的変更の扱いをより慎重にし、README / docs / changelog相当の場所に明記します。

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
- `docs/README.md`
  - 参照導線や保守者向け案内が変わった場合

## Issue化している主な拡張候補

大きめの追加作業や follow-up は GitHub Issues で管理します。beta 前に曖昧な拡張予定表現を docs に残さず、必要なら issue へ切り出します。

現在の大きめの follow-up 例:

- host app 連携前提の DOM windowing / virtualization
- host app 主導の children pagination examples
- deep tree 向けの追加 performance hardening

## 互換性

beta版前は、後方互換性よりも設計の整理を優先します。

beta版以降に公開APIを変更する場合は、既存の利用例が壊れないようにします。

破壊的変更が必要な場合は、README / docs / changelog相当の場所に明記します。
