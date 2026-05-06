# Code quality

このページでは、TreeView gem のコード品質を保つための方針を整理します。

## 基本方針

TreeViewはhost appに組み込まれるgemなので、APIの明確さ、後方互換性、診断しやすさを重視します。

重視すること:

- public API と internal API の境界を明確にする
- invalid option は早めに明確なerrorにする
- host appの責務とgemの責務を混ぜない
- testsとdocsを一緒に更新する
- large treeでstack overflowしない実装を優先する

## Lint

Ruby lintは Standard Ruby を使います。

```bash
bundle exec standardrb
```

PR CIではmerge前にこれを実行します。

## Tests

Ruby specs:

```bash
bundle exec rspec
```

PR CIではRuby specsもmerge前に実行し、Ruby behaviorとpublic API regressionsを早く検出します。

JavaScript tests:

```bash
npm test
```

JavaScript testsは、より広い `main` CIで実行します。JavaScript変更時はローカルでも実行します。

package verification:

```bash
bundle exec rake build
```

package verificationは、release判定前のより広い `main` CIで実行します。

## Error messages

builderやoptionのinvalid valueは、host app開発者が原因を特定しやすいmessageにします。

良いerror:

- どのoptionが不正か分かる
- 期待する型や値が分かる
- 可能なら対象nodeやnode_keyが分かる

## Public API compatibility

公開APIを変更する場合は、以下を確認します。

- `docs/public-api.md`
- `docs/ja/api-overview.md`
- `docs/en/api-overview.md`
- `docs/api.md`
- CHANGELOG

破壊的変更が必要な場合は、release noteにmigration guidanceを書きます。

## Documentation quality

利用者向けdocsには、できるだけ以下を含めます。

- minimal example
- option table
- responsibility boundary
- host app側で実装すること
- 関連docsへのリンク

## Review checklist

- API名が既存docsと揃っているか
- examplesが実際のAPIと一致しているか
- root docs / `docs/ja` / `docs/en` の関係が監査表に反映されているか
- PR CIでlintとRuby specsが通るか
- release判定前に `main` でfull compatibility / package verificationがgreenか
