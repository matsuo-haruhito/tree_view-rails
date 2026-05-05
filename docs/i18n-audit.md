# Documentation i18n audit

This document tracks documentation language status before the `0.1.0` release.

## Current structure

Documentation is moving to language-specific directories.

- `docs/ja/`: Japanese documentation tree
- `docs/en/`: English documentation tree
- `docs/README.md`: language selector
- root-level docs such as `docs/api.md`: kept temporarily for compatibility during migration

## Goal

The documentation should be usable by both Japanese and English readers.

For the initial release, the priority is:

1. Keep the language-specific structure explicit.
2. Keep Japanese and English entry points easy to find.
3. Move or rewrite user-facing docs into both `docs/ja/` and `docs/en/` gradually.
4. Keep canonical behavior/API descriptions in sync while translations are added.
5. Prefer translating user-facing documents before maintainer-only documents.

## Language status labels

| Status | Meaning |
|---|---|
| Split | Separate Japanese and English files exist under `docs/ja/` and `docs/en/`. |
| Japanese canonical | Japanese is currently the more complete canonical source. |
| English canonical | English is currently the more complete canonical source. |
| Bilingual summary | Both languages have a usable summary, but one language may still contain the complete canonical detail. |
| Pending split | Existing root-level doc still needs language-specific copies. |
| Technical asset | Not a prose document that needs translation, such as HTML/CSS mock assets. |

## Translation policy

- Prefer separate files under `docs/ja/` and `docs/en/` for prose docs.
- Keep code examples identical across languages unless a translated comment is more helpful.
- When behavior changes, update the canonical language first, then update the translation in the same PR when practical.
- If a PR cannot update both languages, update this audit so the gap remains visible.
- Root-level docs may remain temporarily for compatibility while the migration is in progress.
- New user-facing docs should be created in both language directories when practical.

## P0: release-blocking language entry points

These should be understandable in both Japanese and English before tagging `v0.1.0`.

| Topic | Japanese | English | Status | Needed work |
|---|---|---|---|---|
| Top-level README | `README.md` | `README.md` | Bilingual summary | Keep short entry content in sync. |
| Docs selector | `docs/README.md` | `docs/README.md` | Split selector | Keep language selector current. |
| Docs index | `docs/ja/README.md` | `docs/en/README.md` | Split | Keep reading order and links in sync. |
| Installation | `docs/ja/installation.md` | `docs/en/installation.md` | Split | Keep requirements, CSS/importmap guidance, CI notes, and packaged file lists in sync. |
| Minimal usage | `docs/ja/minimal-usage.md` | `docs/en/minimal-usage.md` | Split | Keep controller/view/row partial examples in sync. |
| Usage guide | `docs/ja/usage.md` | `docs/en/usage.md` | Split | Keep the practical usage guide in sync; root `docs/usage.md` remains temporarily as detailed legacy reference. |
| API overview | `docs/ja/api-overview.md` | `docs/en/api-overview.md` | Split | Keep high-level API overview in sync with `docs/api.md`. |
| API reference | `docs/api.md` | `docs/en/api.md` | Pending split | Move detailed API reference into language-specific files when practical. |
| Public API policy | `docs/public-api.md` | `docs/en/public-api.md` | Bilingual summary | Split later if the policy grows. |
| Release checklist | `docs/release.md` | `docs/en/release.md` | Bilingual summary | Split later if the release process grows. |

## P1: important feature docs

These should be split after the P0 entry points.

| Topic | Japanese | English | Status | Needed work |
|---|---|---|---|---|
| Selection | `docs/ja/selection.md` | `docs/en/selection.md` | Split | Keep checkbox visibility, payload, disabled state, cascade, indeterminate, and max count docs in sync. |
| Lazy loading | `docs/ja/lazy-loading.md` | `docs/en/lazy-loading.md` | Split | Keep lazy loading hooks, remote-state events, and children pagination guidance in sync. |
| Windowed rendering | `docs/ja/windowed-rendering.md` | `docs/en/windowed-rendering.md` | Split | Keep VisibleRows/RenderWindow/windowed rendering guidance in sync. |
| Persisted state | `docs/ja/persisted-state.md` | `docs/en/persisted-state.md` | Split | Keep StateStore, generator, owner model, and RenderState integration docs in sync. |
| Breadcrumb | `docs/ja/breadcrumb.md` | `docs/en/breadcrumb.md` | Split | Keep helper usage, builders, and responsibility boundaries in sync. |
| Drag and drop | `docs/ja/drag-and-drop.md` | `docs/en/drag-and-drop.md` | Split | Keep row event payload and host app responsibility docs in sync. |
| Children pagination | `docs/ja/children-pagination.md` | `docs/en/children-pagination.md` | Split | Keep server-side pagination guidance in sync. |

## P2: supporting and maintainer docs

These can follow after user-facing coverage is in place.

| Topic | Japanese | English | Status | Needed work |
|---|---|---|---|---|
| Glossary | `docs/ja/glossary.md` | `docs/en/glossary.md` | Split | Keep TreeView terms and responsibility language in sync. |
| Node keys | `docs/ja/node-keys.md` | `docs/en/node-keys.md` | Split | Keep node_key design and collision guidance in sync. |
| Tree diagnostics | `docs/ja/tree-diagnostics.md` | `docs/en/tree-diagnostics.md` | Split | Keep diagnostics APIs and use cases in sync. |
| Cookbook | `docs/cookbook.md` | `docs/en/cookbook.md` | Pending split | Create language-specific files. |
| Depth labels | `docs/depth-labels.md` | `docs/en/depth-labels.md` | Pending split | Create language-specific files. |
| Row status | `docs/row-status.md` | `docs/en/row-status.md` | Pending split | Create language-specific files. |
| Filtered trees | `docs/filtered-trees.md` | `docs/en/filtered-trees.md` | Pending split | Create language-specific files. |
| Rendering boundaries | `docs/rendering-boundaries.md` | `docs/en/rendering-boundaries.md` | Pending split | Create language-specific files. |
| Render scale | `docs/render-scale.md` | `docs/en/render-scale.md` | Pending split | Create language-specific files. |
| Host app extension points | `docs/host-app-extension-points.md` | `docs/en/host-app-extension-points.md` | Pending split | Create language-specific files. |
| Design policy | `docs/design-policy.md` | `docs/en/design-policy.md` | Pending split | Create language-specific files. |
| Development | `docs/development.md` | `docs/en/development.md` | Pending split | Create language-specific files. |
| Code quality | `docs/code-quality.md` | `docs/en/code-quality.md` | Pending split | Create language-specific files. |

## Technical assets

These do not need prose translation unless comments or visible labels become release-facing docs.

| Asset | Status | Notes |
|---|---|---|
| `docs/mockups/default-tree.html` | Technical asset | Visible sample labels may stay as-is unless the mock becomes user-facing localized documentation. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Recommended next PRs

1. Split cookbook, depth labels, and row status docs into language-specific files.
2. Split `api.md` into language-specific API reference files when practical.
3. Continue P2 supporting docs in topic-based PRs.
4. Remove or redirect root-level compatibility docs after language-specific coverage is complete.

## Release decision

Do not block all translation work on a single large PR. For `v0.1.0`, the release should at least have language-specific entry points and a visible i18n backlog so readers know which documents are canonical and which translations are pending.
