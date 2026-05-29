# tree_view docs

`tree_view` documentation is organized by language.

`tree_view` のドキュメントは言語別に管理します。

## Languages

- [日本語ドキュメント](ja/README.md)
- [English documentation](en/README.md)

## Recommended entry points

- [English decision guide](en/decision-guide.md): choose APIs and options by use case.
- [日本語API判断ガイド](ja/decision-guide.md): use caseからAPIやoptionを選ぶための入口。
- [English FAQ](en/faq.md): quick answers about responsibility boundaries and common misunderstandings.
- [日本語FAQ](ja/faq.md): 責務境界とよくある誤解を短く確認する入口。
- [English troubleshooting](en/troubleshooting.md): reverse-lookup entry point for common integration symptoms.
- [日本語Troubleshooting](ja/troubleshooting.md): よくある統合トラブルを症状から逆引きする入口。
- [TreeView mockups](mockups/README.md): static visual reference for baseline DOM structure and interaction states. Start with [review-gallery.html](mockups/review-gallery.html) for the fastest side-by-side first look, open [default-tree.html](mockups/default-tree.html) when you want the baseline DOM structure and shared CSS reference directly, then use the mockup index for the focused pages and each page's role.
- [English Turbo Frame option](en/turbo-frame.md): target TreeView Turbo toggle links at a host-app Turbo Frame without custom JavaScript.
- [日本語Turbo Frame オプション](ja/turbo-frame.md): TreeView の Turbo toggle link を host app の Turbo Frame に向ける設定。
- [English Persisted State](en/persisted-state.md): save and restore TreeView expansion state through host-app-owned storage.
- [日本語Persisted State](ja/persisted-state.md): TreeView の開閉状態を host app 側の保存先で保存・復元するための入口。
- [English resource table bridge](en/resource-table-bridge.md): bridge TreeView row rendering with a separate table layer that owns columns and table state.
- [日本語Resource table bridge](ja/resource-table-bridge.md): 別table layerが列推論やtable stateを持つ場合のTreeView連携。

## Maintainer entry points

- [English documentation](en/README.md): full English docs map, reading order, and maintainer-facing entry points within the English tree.
- [日本語ドキュメント](ja/README.md): 日本語 docs tree の full map、reading order、maintainer-facing entry points。
- [Product Profile](../Product%20Profile.md): repository positioning, source-of-truth order, host app responsibilities, and non-goals.
- [AGENTS.md](../AGENTS.md): repository-specific maintainer workflow, first-read order, and documentation update rules.
- [Documentation maintenance checklist](i18n-audit.md): language-sync rules, technical-asset inventory, and cross-language update coverage.
- [Public API](en/public-api.md) / [公開 API](ja/public-api.md): compatibility contract and the surfaces host apps may use directly.
- [Migration guide](en/migration.md) / [移行ガイド](ja/migration.md): upgrade expectations, deprecations, and release-note reading order.
- [Design policy](en/design-policy.md) / [設計思想と責務範囲](ja/design-policy.md): repository scope, responsibility boundaries, and non-goals.
- [Development](en/development.md) / [開発・保守方針](ja/development.md): CI, local checks, documentation update workflow, and maintenance habits.
- [Code quality](en/code-quality.md) / [コード品質](ja/code-quality.md): lint, tests, error message quality, and documentation quality policy.
- [Release checklist](en/release.md) / [リリースチェックリスト](ja/release.md): release workflow, CI and package verification, and changelog expectations.
- [CHANGELOG.md](../CHANGELOG.md): release-facing summary of shipped public changes, compatibility notes, and notable documentation additions.

## Maintenance

Documentation language-sync rules and ongoing maintenance checks are tracked in [Documentation maintenance checklist](i18n-audit.md).

ドキュメントの日英同期ルールと継続的な保守チェックは [Documentation maintenance checklist](i18n-audit.md) で管理します。

## Policy

- `docs/ja/` is the Japanese documentation tree and is the primary canonical source while Japanese coverage is more complete.
- `docs/en/` is the English documentation tree.
- Root-level docs should stay limited to intentional entry points, maintenance notes, and technical assets.
- New or substantially updated user-facing docs should be added under both `docs/ja/` and `docs/en/` when practical.

## 方針

- `docs/ja/` は日本語ドキュメントです。日本語側の内容がより充実している間は、主なcanonical sourceとして扱います。
- `docs/en/` は英語ドキュメントです。
- root直下のdocsは、意図した入口、保守メモ、technical asset に限定します。
- 利用者向けdocsを新規追加または大きく更新する場合は、可能な限り `docs/ja/` と `docs/en/` の両方に追加します。
