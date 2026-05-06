# Documentation i18n audit

This document tracks documentation language status before the `0.1.0` release.

## Current structure

Documentation is moving to language-specific directories.

- `docs/ja/`: Japanese documentation tree
- `docs/en/`: English documentation tree
- `docs/README.md`: language selector
- root-level compatibility pages: short language selectors for older links

## Goal

The documentation should be usable by both Japanese and English readers.

For the initial release, the priority is:

1. Keep the language-specific structure explicit.
2. Keep Japanese and English entry points easy to find.
3. Keep canonical behavior/API descriptions in sync.
4. Prefer language-specific prose docs under `docs/ja/` and `docs/en/`.
5. Keep root-level compatibility pages short.

## Language status labels

| Status | Meaning |
|---|---|
| Split | Separate Japanese and English files exist under `docs/ja/` and `docs/en/`. |
| Bilingual summary | Both languages have a usable summary, but one language may still contain more detail. |
| Compatibility selector | Root-level page kept as a short language selector for older links. |
| Technical asset | Not a prose document that needs translation. |

## P0: release-blocking language entry points

| Topic | Japanese | English | Status | Notes |
|---|---|---|---|---|
| Top-level README | `README.md` | `README.md` | Bilingual summary | Keep short entry content in sync. |
| Docs selector | `docs/README.md` | `docs/README.md` | Compatibility selector | Keep language selector current. |
| Docs index | `docs/ja/README.md` | `docs/en/README.md` | Split | Keep reading order and links in sync. |
| Installation | `docs/ja/installation.md` | `docs/en/installation.md` | Split | Keep requirements and asset/importmap guidance in sync. |
| Minimal usage | `docs/ja/minimal-usage.md` | `docs/en/minimal-usage.md` | Split | Keep examples in sync. |
| Usage guide | `docs/ja/usage.md` | `docs/en/usage.md` | Split | Root `docs/usage.md` remains as compatibility reference for now. |
| API overview | `docs/ja/api-overview.md` | `docs/en/api-overview.md` | Split | Keep in sync with API reference docs. |
| API reference | `docs/ja/api.md` | `docs/en/api.md` | Split | Root `docs/api.md` remains as old compatibility reference for now. |
| Public API policy | `docs/ja/public-api.md` | `docs/en/public-api.md` | Split | Root `docs/public-api.md` is a compatibility selector. |
| Release checklist | `docs/ja/release.md` | `docs/en/release.md` | Split | Root `docs/release.md` is a compatibility selector. |

## P1: important feature docs

| Topic | Japanese | English | Status | Notes |
|---|---|---|---|---|
| Selection | `docs/ja/selection.md` | `docs/en/selection.md` | Split | Keep selection behavior in sync. |
| Lazy loading | `docs/ja/lazy-loading.md` | `docs/en/lazy-loading.md` | Split | Keep hooks and remote-state guidance in sync. |
| Windowed rendering | `docs/ja/windowed-rendering.md` | `docs/en/windowed-rendering.md` | Split | Keep VisibleRows/RenderWindow guidance in sync. |
| Persisted state | `docs/ja/persisted-state.md` | `docs/en/persisted-state.md` | Split | Keep StateStore/generator guidance in sync. |
| Breadcrumb | `docs/ja/breadcrumb.md` | `docs/en/breadcrumb.md` | Split | Keep helper usage in sync. |
| Drag and drop | `docs/ja/drag-and-drop.md` | `docs/en/drag-and-drop.md` | Split | Keep row event payload guidance in sync. |
| Children pagination | `docs/ja/children-pagination.md` | `docs/en/children-pagination.md` | Split | Keep server-side pagination guidance in sync. |

## P2: supporting and maintainer docs

| Topic | Japanese | English | Status | Notes |
|---|---|---|---|---|
| Glossary | `docs/ja/glossary.md` | `docs/en/glossary.md` | Split | Keep terms in sync. |
| Node keys | `docs/ja/node-keys.md` | `docs/en/node-keys.md` | Split | Keep node_key guidance in sync. |
| Tree diagnostics | `docs/ja/tree-diagnostics.md` | `docs/en/tree-diagnostics.md` | Split | Keep diagnostics guidance in sync. |
| Cookbook | `docs/ja/cookbook.md` | `docs/en/cookbook.md` | Split | Keep examples in sync. |
| Depth labels | `docs/ja/depth-labels.md` | `docs/en/depth-labels.md` | Split | Keep builder usage in sync. |
| Row status | `docs/ja/row-status.md` | `docs/en/row-status.md` | Split | Keep row state guidance in sync. |
| Filtered trees | `docs/ja/filtered-trees.md` | `docs/en/filtered-trees.md` | Split | Keep modes in sync. |
| Rendering boundaries | `docs/ja/rendering-boundaries.md` | `docs/en/rendering-boundaries.md` | Split | Keep responsibility boundaries in sync. |
| Render scale | `docs/ja/render-scale.md` | `docs/en/render-scale.md` | Split | Keep large-tree guidance in sync. |
| Host app extension points | `docs/ja/host-app-extension-points.md` | `docs/en/host-app-extension-points.md` | Split | Keep extension hooks in sync. |
| Design policy | `docs/ja/design-policy.md` | `docs/en/design-policy.md` | Split | Root `docs/design-policy.md` is a compatibility selector. |
| Development | `docs/ja/development.md` | `docs/en/development.md` | Split | Root `docs/development.md` is a compatibility selector. |
| Code quality | `docs/ja/code-quality.md` | `docs/en/code-quality.md` | Split | Root `docs/code-quality.md` is a compatibility selector. |

## Technical assets

| Asset | Status | Notes |
|---|---|---|
| `docs/mockups/default-tree.html` | Technical asset | No translation needed. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Remaining cleanup

- Replace root `docs/api.md` with a short language selector when practical.
- Consider replacing root `docs/usage.md` with a short language selector after confirming no older links need the full legacy reference.
- Keep `docs/ja/` and `docs/en/` in sync for future user-facing changes.
