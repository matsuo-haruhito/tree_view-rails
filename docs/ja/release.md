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

release flow:

1. `main` 向けにrelease preparation PRを作る。
2. target version がまだ設定されていない場合は `lib/tree_view/version.rb` を更新する。
3. `CHANGELOG.md` の `Unreleased` を日付付きversion sectionへ移す。
4. PRを `main` にmergeする。
5. main-push full CIがgreenであることを確認する。
6. greenな `main` commit に `vX.Y.Z` tag を付ける。
7. 必要に応じてGitHub Releaseを作成する。
8. 必要に応じてgem publishする。

`release/x.y` branch は、複数minor lineの並行保守、長期RC検証、security/compatibility patchなどが必要になった時だけ導入します。

## Initial release target

初回 `0.1.0` release は、すべての予定機能を含めることより、整合したdocumented baselineを優先します。

Minimum release conditions:

- `TreeView::VERSION` が `0.1.0` になっている
- `CHANGELOG.md` に日付付き `0.1.0` section がある
- core tree construction and rendering helpers are covered by specs
- static rendering works without dedicated JavaScript
- Turbo path-builder integration is documented
- selection params parsing and checkbox rendering are documented when included
- asset and importmap setup is documented
- public API and compatibility boundaries are documented
- package file list includes Rails integration files and docs
- main-push full CI is green

## Code and tests

Local checks:

```bash
bundle exec standardrb
bundle exec rake
bundle exec rake build
npm test
```

Main-push CI checks:

- Ruby spec matrix
- Rails version matrix
- JavaScript tests through `npm ci`
- Gem package verification

Pull Request CIは軽量lint中心です。release判定には、merge後の `main` full CIを使います。

## Documentation

Public usageや公開optionを変えた場合は、関連docsとCHANGELOGを更新します。

- `README.md`
- `docs/ja/README.md`
- `docs/en/README.md`
- `docs/ja/api.md`
- `docs/en/api.md`
- `docs/ja/public-api.md`
- `docs/en/public-api.md`
- feature-specific docs
- `CHANGELOG.md`

## CHANGELOG policy

releaseごとに `CHANGELOG.md` へ日付付きentryを追加します。

使うcategory:

- Added
- Changed
- Fixed
- Deprecated
- Removed
- Documentation

breaking changeやdeprecationにはmigration noteを書きます。

## Gem package

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
