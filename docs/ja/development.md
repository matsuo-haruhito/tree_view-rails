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

ローカルの JavaScript 作業では Node 22 を使ってください。repository root の `.nvmrc` が CI の JavaScript lane とそろった、推奨 Node major version の source of truth です。

現状は `npm install` を使い続けてください。repo には `package-lock.json` を commit していますが、まだ `package.json` と同期していないため、ローカルセットアップと Pull Request CI は、registry-enabled な環境で lockfile refresh が完了するまで `npm install` を前提にしています。現在の CI と install path の整理は [導入手順](installation.md) を参照してください。

## よく使うコマンド

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm run test:js
npm test
npm run test:entrypoints
npm run test:browser
```

CI の JavaScript lane と同じ entrypoint、unit、browser smoke coverage をまとめて確認したい場合は `npm run test:js` を使います。失敗箇所を切り分ける場合は個別の npm command を使ってください。

Rails version matrixを確認する場合:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rake
```

## Public API compatibility specs

Public API compatibility specsは、documented Ruby entry points、helper methods、grouped options、JavaScript exportsが意図せず削除・renameされることを防ぐためのtestsです。これらのspecは、実装詳細を網羅するのではなく、APIの存在と代表的な互換挙動に絞ります。

意図的なbreaking changeを受け入れる場合は、public API docsとcompatibility specsを同時に更新し、documented contractとtest coverageを同期させます。

`config/public_api_manifest.yml` は、current first slice の documented Ruby module methods、public constants、helper names を表す machine-readable source of truth です。ここに entry を追加・rename・削除する場合は、manifest 自体を更新したうえで `docs/en/public-api.md` と `docs/ja/public-api.md` をそろえ、同じ surface を名前で案内している README / usage docs / feature docs を見直し、利用者向けの変更点を `CHANGELOG.md` に残し、必要なら `docs/en/release.md` / `docs/ja/release.md` の release note や migration expectation も更新してください。

## JavaScript browser smoke tests

Unit-style JavaScript testsはVitestとjsdomで実行します。

```bash
npm test
```

`app/javascript/tree_view/index.js` を直接読む entrypoint smoke check は次で実行します。

```bash
npm run test:entrypoints
```

このcheckで、documented controller exports と `registerTreeViewControllers` helper が importmap entrypoint とずれないようにします。Node 側の assertions を実行する前に Ruby で `config/public_api_manifest.yml` を読み、`javascript_package_root` section を JSON として出力します。manifest loader failure を調べる場合は、repository root から Ruby が使える状態で実行してください。

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

Pull Request の Rails lanes では、lower / current / next-major の代表範囲に絞るため Rails 7.1 は意図的に含めていません。Rails 7.1 は `main` push の full Rails matrix で確認する最終互換ゲートです。

`README.md`、`docs/**`、`Product Profile.md`、`CHANGELOG.md`、`AGENTS.md` だけに触れる docs-only Pull Request では、`lint` と `pr_specs` はそのまま残しつつ、representative Rails job を short-circuit します。branch protection のため、check 名はそのまま維持します。JavaScript job も docs-only Pull Request では short-circuit しますが、`docs/mockups/**` が変わった場合は例外です。mockup 変更時は branch を checkout し、Playwright を install して `npm run test:browser` を実行します。`.github/workflows/**` も変更する Pull Request ではこの shortcut を使わず、通常の PR lanes を確認します。

`main` が進んで branch が `diverged` になった後は、green checks だけでは merge ready と判断しません。`mergeable`、changed files、risk、behind の大きさを確認します。GitHub が `mergeable: false` を返す場合、behind が大きい場合、または workflow 定義、public API、spec、shared docs inventory に触れる Pull Request では、branch refresh 後に fresh CI を観測することを優先します。小さく少しだけ behind している docs-only 変更では、changed files が clean に適用でき、`mergeable` が true で、同じ check 名が green のままなら、過度に重い refresh を必須にしなくてかまいません。

`main` へのpushでは、より広い互換性確認とrelease向けのchecksも実行します。

- Ruby version matrix
- full Rails version matrix（Rails 7.1 を含む）
- gem package verification

## 変更時の確認ポイント

### Ruby APIを変更した場合

- specを追加または更新する
- Ruby file や Ruby spec を変更した後は `bundle exec standardrb` を確認する。connector や GitHub API 経由の編集では、ローカル editor の final newline handling を通らないことがあるため特に確認する。
- final newline missing や trailing whitespace のような機械的な整形漏れが出た場合は、PR を開く前に formatter または最小の file rewrite で直す。
- `docs/ja/api-overview.md` / `docs/en/api-overview.md` を確認する
- documented entry points、helpers、optionsを意図的に変更する場合はpublic API compatibility specsを更新する
- `config/public_api_manifest.yml` を更新した場合は、`docs/en/public-api.md` / `docs/ja/public-api.md` をそろえたうえで、関連する README、usage docs、feature docs、`CHANGELOG.md`、`docs/en/release.md` / `docs/ja/release.md` も見直す
- 必要に応じて `docs/en/api.md` / `docs/ja/api.md` を更新する
- CHANGELOGを更新する

### JavaScriptを変更した場合

- `npm test` を確認する
- documented controller exports や entrypoint wiring を変える場合は `npm run test:entrypoints` を確認する
- Browser interaction、focus、drag/drop、実際のform controlsに影響する場合は `npm run test:browser` を確認する
- importmap / packaged files に影響がないか確認する
- JavaScript entrypointの互換性を確認し、documented exportsを意図的に変更する場合はcompatibility specsを更新する

### docsを変更した場合

Docs PR を開く前に、`docs/i18n-audit.md` を cross-language checklist として短く見返します。

- 変更が共有の user-facing guidance に影響するかを確認し、日本語・英語を対応させる必要があるか判断する
- `CHANGELOG.md`、release docs、README / docs index link、root-level docs policy の更新が必要か判断する
- public API、compatibility、installation、release、migration docs に触れる場合は、PR scope を狭める前に `docs/i18n-audit.md` の update matrix を確認する
- `docs/mockups/` の focused mockup を追加・rename・削除する場合は、`docs/mockups/README.md` の Files table、`docs/mockups/review-gallery.html`、browser smoke target list が同じ inventory を説明しているか確認する
- 片方の言語や関連 doc を意図的に後回しにする場合は、docs-only CI shortcut に黙って頼らず、PR 本文または follow-up issue で mismatch を見える状態にする

- 日本語・英語の対応関係を確認する
- `docs/i18n-audit.md` を更新する
- root互換docを残すか、言語別docへ誘導するかを判断する
- `README.md`、`docs/**`、`Product Profile.md`、`CHANGELOG.md`、`AGENTS.md` だけのPRでは、docs-only CI short-circuit が今回も妥当かを確認してから使う
- `.github/workflows/**` も含むPRは、docs-only shortcut の候補ではなく full CI change として扱う
- Pull Request で `docs/mockups/` の focused mockup を追加・rename・削除する場合は、mockup inventory の導線もそろえる。`docs/mockups/README.md` を更新し、`docs/mockups/review-gallery.html` のcardを追加または調整し、recommended review flow が変わるなら root README と言語別 README の入口を見直し、特定feature guideと一緒に読むmockupならそのfeature docからの導線も追加する。
- docs-only CI が JavaScript を skip するのは、`docs/mockups/**` が変わっていない場合だけです。focused mockup files が変わると、CI は browser smoke target list に対して `npm run test:browser` を実行します。ただし、この smoke は README Files table、review gallery、既存 mockup inventory、visual correctness がすべて同期していることまでは保証しません。既存の mockup files と docs index がすでに食い違っている場合は、gallery redesign や mockup HTML/CSS 変更を checklist-only PR に混ぜず、別の docs follow-up として扱う。

## release前の確認

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `npm run test:entrypoints`
- `npm run test:browser`
- `bundle exec rake build`
- gem package contents
- `config/public_api_manifest.yml` が documented Ruby / helper entry points と public API docs に追従していることを確認する
- CHANGELOG
- docs index / i18n audit

## branch / PR方針

- 小さな機能変更は小さなPRにする
- docs-onlyで単純な分割や棚卸しは大きめのPRでもよい
- Pull Request を作成する前に、同じ Issue を close する open Pull Request が既にないか確認する。`Closes #NNN`、linked Issue、changed files の重なりを見ます。
- duplicate close-check で既存候補が見つかった場合は、新規 PR 作成を止め、既存 PR に review / follow-up / supersede の文脈を寄せるか、maintainer に採用方針の判断を依頼する。
- merge前にPR CIを通す
- docs-only PR では representative Rails / JavaScript job を short-circuit できるが、merge は同じ check 名が green のままで待つ
- workflow 定義を変えるPRは、merge前に fresh な head SHA で Checks を観測する
- PR が `main` から `diverged` している場合は、古い green CI だけに頼らず、refresh するかを決める前に mergeability、changed files、risk、behind count を確認する
- release判定前に `main` でfull compatibility / package verificationを確認する
