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
- [English resource table bridge](en/resource-table-bridge.md): bridge TreeView row rendering with a separate table layer that owns columns and table state.
- [日本語Resource table bridge](ja/resource-table-bridge.md): 別table layerが列推論やtable stateを持つ場合のTreeView連携。

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
