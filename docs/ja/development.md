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
npm run test:browser
```

Rails version matrixを確認する場合:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

## JavaScript browser smoke tests

Unit-style JavaScript testsはVitestとjsdomで実行します。

```bash
npm test
```

Browser-level smoke testsはPlaywrightで実行します。

```bash
npm run test:browser
```

Browser smoke suiteは、実ブラウザのevent loop、focus handling、drag/drop APIで差が出やすい代表的なinteraction flowを確認するために使います。Keyboard navigation、expand/collapse、checkbox cascade、lazy-loading state changes、transfer payloads、row form controlsとtree behaviorの共存を、小さく安定したtestsで守ります。

## CI方針

Pull Requestでは、日常的な変更を守る高速なRuby checksとJavaScript testsを実行します。

- Ruby lint: `bundle exec standardrb`
- Ruby specs: `bundle exec rspec`
- JavaScript unit and browser smoke tests: `npm run test:js`

`main` へのpushでは、より広い互換性確認とrelease向けのchecksも実行します。

- Ruby version matrix
- Rails version matrix
- gem package verification

## 変更時の確認ポイント

### Ruby APIを変更した場合

- specを追加または更新する
- `docs/ja/api-overview.md` / `docs/en/api-overview.md` を確認する
- 必要に応じて `docs/api.md` を更新する
- CHANGELOGを更新する

### JavaScriptを変更した場合

- `npm test` を確認する
- Browser interaction、focus、drag/drop、実際のform controlsに影響する場合は `npm run test:browser` を確認する
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
- `npm run test:browser`
- `bundle exec rake build`
- gem package contents
- CHANGELOG
- docs index / i18n audit

## branch / PR方針

- 小さな機能変更は小さなPRにする
- docs-onlyで単純な分割や棚卸しは大きめのPRでもよい
- merge前にPR CIを通す
- release判定前に `main` でfull compatibility / package verificationを確認する
