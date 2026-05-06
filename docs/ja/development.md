# Development

このページでは、TreeView gem の開発・保守に必要な基本作業を整理します。

## セットアップ

```bash
bundle install
npm install
```

Dockerを使う場合:

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app npm install
```

## よく使うコマンド

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm test
```

Rails version matrixを確認する場合:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

## CI方針

Pull Requestでは、日常的な変更を守る高速なRuby checksを実行します。

- Ruby lint: `bundle exec standardrb`
- Ruby specs: `bundle exec rspec`

`main` へのpushでは、より広い互換性確認とrelease向けのchecksを実行します。

- Ruby version matrix
- Rails version matrix
- JavaScript tests
- gem package verification

この方針により、PRではRuby behaviorとpublic API regressionsを早く検出し、重い互換性確認とpackage検証は `main` / release判定で確認します。

## 変更時の確認ポイント

### Ruby APIを変更した場合

- specを追加または更新する
- `docs/ja/api-overview.md` / `docs/en/api-overview.md` を確認する
- 必要に応じて `docs/api.md` を更新する
- CHANGELOGを更新する

### JavaScriptを変更した場合

- `npm test` を確認する
- importmap / packaged files に影響がないか確認する
- JavaScript entrypointの互換性を確認する

### docsを変更した場合

- 日本語・英語の対応関係を確認する
- `docs/i18n-audit.md` を更新する
- root互換docを残すか、言語別docへ誘導するかを判断する

## release前の確認

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `bundle exec rake build`
- gem package contents
- CHANGELOG
- docs index / i18n audit

## branch / PR方針

- 小さな機能変更は小さなPRにする
- docs-onlyで単純な分割や棚卸しは大きめのPRでもよい
- merge前にPR CIを通す
- release判定前に `main` でfull compatibility / package verificationを確認する
