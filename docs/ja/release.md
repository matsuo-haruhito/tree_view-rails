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

`bundle exec rake release:check` は current `TreeView::VERSION` と日付付き `CHANGELOG.md` section の整合を確認し、gem build、release-facing files の packaging、`bundle exec ruby -Ilib -e 'require "tree_view"'` による load check までまとめて実行します。main-push の `gem_package` CI job では、built gem に Rails helper / view partial / locale / docs / JavaScript / CSS / importmap の代表ファイルが残っていることを `ruby script/check_gem_package_contents.rb tree_view-*.gem` でも確認します。`vX.Y.Z` tag がまだ無い段階では tag alignment は skip し、tag 作成後はその release tag が current `HEAD` を指していることを確認します。

Pull Request CI の確認項目:

- Ruby lint: `bundle exec standardrb`
- Ruby specs: `bundle exec rspec`
- representative Rails compatibility checks: `gemfiles/rails_7_0.gemfile`、`gemfiles/rails_7_2.gemfile`、`gemfiles/rails_8_0.gemfile`
- JavaScript tests: `npm install`、Playwright browser setup、`npm run test:js`
- package-sensitive path を触るPRでの Gem package verification

package-sensitive path には、`tree_view.gemspec`、`script/check_gem_package_contents.rb`、`.github/workflows/ci.yml`、`lib/**`、Rails integration files である `app/helpers/**`、`app/views/**`、`app/assets/**`、`app/javascript/**`、さらに `config/importmap.tree_view.rb` と `config/locales/**` が含まれます。これらを触るPRでは `gem build tree_view.gemspec`、`ruby script/check_gem_package_contents.rb tree_view-*.gem`、`gem install tree_view-*.gem`、`ruby -e "require 'tree_view'"` を実行します。prose-only docs PR は、その package-sensitive path も触らない限り、従来どおり軽い docs-only 挙動を維持します。

`main` push CI の確認項目:

- Ruby version matrix
- Rails version matrix
- `package-lock.json` が `package.json` と同期するまでの間は、`npm install` と `npm run test:js` による JavaScript tests
- Rails helper / view partial / locale / docs / JavaScript / CSS / importmap の代表ファイルを含む Gem package verification

merge前にPR CIを通します。release判定には、full compatibility matrices、JavaScript coverage、unconditional package verificationを含む、より広い `main` CIを使います。

## ドキュメント

Public usageや公開optionを変えた場合は、関連docsとCHANGELOGを更新します。

documented な host-app wiring surface または machine-readable public contract surface、たとえば package-root JavaScript export、controller identifier、grouped option key、documented event name / detail key、documented `data-tree-view-*` integration hook、selection controller の host-element value attribute を変更する場合は、public API docs や関連feature page と一緒に `config/public_api_manifest.yml` も見直してください。

`config/public_api_manifest.yml` は、package-root export、controller identifier、grouped option key、documented event detail key の machine-readable source of truth です。一方で、そこに export していない documented wiring attribute や hook については、public API docs と feature docs を source of truth として扱います。

public API manifest を変更する場合は、tag を打つ前に release-facing な導線も確認してください。

- manifest の変更が `docs/en/public-api.md`、`docs/ja/public-api.md`、影響する feature page に反映されている
- `CHANGELOG.md` が、user-visible な compatibility surface を適切な release category で説明している
- breaking change、削除、deprecation には、manifest や spec の説明だけでなく migration note がある
- docs-only の manifest guidance 変更は Documentation entry として扱い、runtime behavior の変更を示唆しない

public behavior や public compatibility surface が変わるときに確認する docs:

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

public API manifest の変更は、user-visible な影響に合わせて記録します。後方互換な public surface 追加や変更は Added / Changed、migration note が必要な互換性変更は Deprecated / Removed、runtime contract を変えない manifest や docs guidance の変更は Documentation に入れてください。

breaking changeやdeprecationにはmigration noteを書きます。

## gem package

release前に確認すること:

- `TreeView::VERSION` がrelease versionと一致することを確認する
- `gem build tree_view.gemspec` を実行する
- built gem に対して `ruby script/check_gem_package_contents.rb tree_view-*.gem` を実行する
- 生成gemをローカルinstallして `require "tree_view"` を確認する
- packaged filesに以下が含まれることを確認する
  - `lib/**/*`
  - Rails helpers, views, stylesheets, JavaScript, importmap files
  - `app/helpers/tree_view_helper.rb`
  - `app/views/tree_view/_tree_row.html.erb`
  - `app/javascript/tree_view/index.js`
  - `app/assets/stylesheets/tree_view.scss`
  - `config/importmap.tree_view.rb`
  - `config/locales/tree_view.toolbar.en.yml`
  - `README.md`
  - `CHANGELOG.md`
  - `docs/**/*`
  - `docs/en/release.md`
  - `LICENSE*`

## Repository

- `main` がgreenであることを確認する
- released versionのtagを `main` に付ける
- 必要に応じてGitHub Releaseを作る
- release notesから主なclosed issues / merged PRsへリンクする
