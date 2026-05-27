# Release checklist

このページでは、`tree_view` gemをリリースする前に確認する手順と方針をまとめます。

## Versioning policy

`tree_view` は semantic versioning を前提にします。

- patch version: 挙動を変えないbug fixやdocs修正
- minor version: 後方互換なAPI、option、hook、docs追加
- major version: 意図的なbreaking change

`1.0.0` 未満でも、breaking change は意図的に扱い、`CHANGELOG.md` と関連docsにmigration noteを書きます。

## Release branch and tag policy

通常のリリースでは、長期運用する `release/*` branch は作らず、`main` のgreenなcommitに `vX.Y.Z` tag を付けます。

releaseの流れ:

1. `main` 向けにrelease preparation PRを作る。
2. target version がまだ設定されていない場合は `lib/tree_view/version.rb` を更新する。
3. `CHANGELOG.md` の `Unreleased` を日付付きversion sectionへ移す。
4. PRを `main` にmergeする。
5. main-push full CIがgreenであることを確認する。
6. greenな `main` commit に `vX.Y.Z` tag を付ける。
7. 必要に応じてGitHub Releaseを作成する。
8. 必要に応じてgem publishする。

`release/x.y` branch は、複数minor lineの並行保守、長期RC検証、security/compatibility patchなどが必要になった時だけ導入します。

## 初回リリースの目標

初回 `0.1.0` release は、すべての予定機能を含めることより、整合したdocumented baselineを優先します。

最低限のリリース条件:

- `TreeView::VERSION` が `0.1.0` になっている
- `CHANGELOG.md` に日付付き `0.1.0` section がある
- core tree construction and rendering helpers がspecでカバーされている
- 専用JavaScriptがなくてもstatic renderingが動作する
- Turbo path-builder integration が文書化されている
- 含まれる場合は、selection params parsing と checkbox rendering が文書化されている
- asset と importmap のセットアップが文書化されている
- public API と compatibility boundary が文書化されている
- package file list に Rails integration files と docs が含まれている
- main-push full CI が green である

## コードとテスト

committed `package-lock.json` はまだ `package.json` と同期していないため、JavaScript lane は local setup / CI ともに現時点では `npm install` 前提です。lockfile refresh 作業が入ったら、release checks も `npm ci` 前提へ戻します。

ローカル確認:

```bash
bundle exec rake release:check
bundle exec standardrb
bundle exec rake
npm run test:js
```

`bundle exec rake release:check` は current `TreeView::VERSION` と日付付き `CHANGELOG.md` section の整合を確認し、gem build、release-facing files の packaging、`bundle exec ruby -Ilib -e 'require "tree_view"'` による load check までまとめて実行します。`vX.Y.Z` tag がまだ無い段階では tag alignment は skip し、tag 作成後はその release tag が current `HEAD` を指していることを確認します。

Pull Request CI の確認項目:

- Ruby lint: `bundle exec standardrb`
- Ruby specs: `bundle exec rspec`
- representative Rails compatibility checks: `gemfiles/rails_7_0.gemfile` と `gemfiles/rails_8_0.gemfile`
- JavaScript tests: `npm install`、Playwright browser setup、`npm run test:js`

`main` push CI の確認項目:

- Ruby version matrix
- Rails version matrix
- `package-lock.json` が `package.json` と同期するまでの間は、`npm install` と `npm run test:js` による JavaScript tests
- Gem package verification

merge前にPR CIを通します。互換性matrix、JavaScript coverage、package verificationを含むため、release判定にはより広い `main` CIを使います。

## ドキュメント

Public usageや公開optionを変えた場合は、関連docsとCHANGELOGを更新します。

package-root JavaScript export、controller identifier、grouped option key、documented event name / detail key のような machine-readable public contract surface を変える場合は、public API docs や関連feature page と一緒に `config/public_api_manifest.yml` も見直してください。

- `README.md`
- `docs/ja/README.md`
- `docs/en/README.md`
- `docs/ja/api.md`
- `docs/en/api.md`
- `docs/ja/public-api.md`
- `docs/en/public-api.md`
- 変更した contract surface の source of truth になっている場合は `config/public_api_manifest.yml`
- feature-specific docs
- `docs/i18n-audit.md`（documentation maintenance checklist）
- `CHANGELOG.md`

## CHANGELOG方針

releaseごとに `CHANGELOG.md` へ日付付きentryを追加します。

使うcategory:

- Added
- Changed
- Fixed
- Deprecated
- Removed
- Documentation

breaking changeやdeprecationにはmigration noteを書きます。

## gem package

release前に確認すること:

- `TreeView::VERSION` がrelease versionと一致することを確認する
- `gem build tree_view.gemspec` を実行する
- 生成gemをローカルinstallして `require "tree_view"` を確認する
- packaged filesに以下が含まれることを確認する
  - `lib/**/*`
  - Rails helpers, views, stylesheets, JavaScript, importmap files
  - `README.md`
  - `CHANGELOG.md`
  - `docs/**/*`
  - `LICENSE*`

## Repository

- `main` がgreenであることを確認する
- released versionのtagを `main` に付ける
- 必要に応じてGitHub Releaseを作る
- release notesから主なclosed issues / merged PRsへリンクする
