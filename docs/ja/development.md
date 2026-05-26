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
npm run test:entrypoints
npm run test:browser
```

Rails version matrixを確認する場合:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle exec rake
```

## Public API compatibility specs

Public API compatibility specsは、documented Ruby entry points、helper methods、grouped options、JavaScript exportsが意図せず削除・renameされることを防ぐためのtestsです。これらのspecは、実装詳細を網羅するのではなく、APIの存在と代表的な互換挙動に絞ります。

意図的なbreaking changeを受け入れる場合は、public API docsとcompatibility specsを同時に更新し、documented contractとtest coverageを同期させます。

## JavaScript browser smoke tests

Unit-style JavaScript testsはVitestとjsdomで実行します。

```bash
npm test
```

`app/javascript/tree_view/index.js` を直接読む entrypoint smoke check は次で実行します。

```bash
npm run test:entrypoints
```

このcheckで、documented controller exports と `registerTreeViewControllers` helper が importmap entrypoint とずれないようにします。

Browser-level smoke testsはPlaywrightで実行します。

```bash
npm run test:browser
```

Browser smoke suiteは、実ブラウザのevent loop、focus handling、drag/drop APIで差が出やすい代表的なinteraction flowを確認するために使います。Keyboard navigation、expand/collapse、checkbox cascade、lazy-loading state changes、transfer payloads、row form controlsとtree behaviorの共存を、小さく安定したtestsで守ります。

browser-level の accessibility smoke を追加するときは、tree や treegrid 前提の指摘を無言で suppress しないでください。TreeView の documented な table-first policy に基づいて意図的に許容する fixture がある場合は、近くの comment や suppression note から `docs/en/accessibility-semantics.md` または `docs/ja/accessibility-semantics.md` を参照し、row-level ARIA on table rows、`aria-controls` 非採用、host app 側 keyboard flow など、どの policy を根拠にしているかを短く明記します。

## CI方針

Pull Requestでは、日常的な変更を守る高速なRuby checksとJavaScript testsを実行します。

- Ruby lint: `bundle exec standardrb`
- Ruby specs: `bundle exec rspec`
- representative Rails compatibility checks: `gemfiles/rails_7_0.gemfile`、`gemfiles/rails_7_2.gemfile`、`gemfiles/rails_8_0.gemfile`
- JavaScript entrypoint、unit、browser smoke tests: `npm run test:js`

`README.md` と `docs/**` だけに触れる docs-only Pull Request では、`lint` と `pr_specs` はそのまま残しつつ、representative Rails job と JavaScript job を short-circuit します。branch protection のため、check 名はそのまま維持します。`.github/workflows/**` も変更する Pull Request ではこの shortcut を使わず、通常の PR lanes を確認します。

`main` へのpushでは、より広い互換性確認とrelease向けのchecksも実行します。

- Ruby version matrix
- full Rails version matrix
- gem package verification

## 変更時の確認ポイント

### Ruby APIを変更した場合

- specを追加または更新する
- `docs/ja/api-overview.md` / `docs/en/api-overview.md` を確認する
- documented entry points、helpers、optionsを意図的に変更する場合はpublic API compatibility specsを更新する
- 必要に応じて `docs/api.md` を更新する
- CHANGELOGを更新する

### JavaScriptを変更した場合

- `npm test` を確認する
- documented controller exports や entrypoint wiring を変える場合は `npm run test:entrypoints` を確認する
- Browser interaction、focus、drag/drop、実際のform controlsに影響する場合は `npm run test:browser` を確認する
- importmap / packaged files に影響がないか確認する
- JavaScript entrypointの互換性を確認し、documented exportsを意図的に変更する場合はcompatibility specsを更新する

### docsを変更した場合

- 日本語・英語の対応関係を確認する
- `docs/i18n-audit.md` を更新する
- root互換docを残すか、言語別docへ誘導するかを判断する
- `README.md` と `docs/**` だけのPRでは、docs-only CI short-circuit が今回も妥当かを確認してから使う
- `.github/workflows/**` も含むPRは、docs-only shortcut の候補ではなく full CI change として扱う

## release前の確認

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `npm run test:entrypoints`
- `npm run test:browser`
- `bundle exec rake build`
- gem package contents
- CHANGELOG
- docs index / i18n audit

## branch / PR方針

- 小さな機能変更は小さなPRにする
- docs-onlyで単純な分割や棚卸しは大きめのPRでもよい
- merge前にPR CIを通す
- docs-only PR では representative Rails / JavaScript job を short-circuit できるが、merge は同じ check 名が green のままで待つ
- workflow 定義を変えるPRは、merge前に fresh な head SHA で Checks を観測する
- release判定前に `main` でfull compatibility / package verificationを確認する