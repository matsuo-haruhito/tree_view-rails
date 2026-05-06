# Documentation i18n audit

This document tracks documentation language status before the `0.1.0` release.

## Current structure

Documentation is organized around language-specific directories.

- `docs/ja/`: Japanese documentation tree
- `docs/en/`: English documentation tree
- `docs/README.md`: language selector
- root-level compatibility pages: short language selectors for older links, except `docs/api.md` which remains a longer compatibility reference for now

## Goal

The documentation should be usable by both Japanese and English readers.

For the initial release, the priority is:

1. Keep the language-specific structure explicit.
2. Keep Japanese and English entry points easy to find.
3. Keep canonical behavior/API descriptions in sync.
4. Prefer language-specific prose docs under `docs/ja/` and `docs/en/`.
5. Keep root-level compatibility pages short when practical.

## Language status labels

| Status | Meaning |
|---|---|
| Split | Separate Japanese and English files exist under `docs/ja/` and `docs/en/`. |
| Bilingual summary | Both languages have a usable summary, but one language may still contain more detail. |
| Compatibility selector | Root-level page kept as a short language selector for older links. |
| Legacy compatibility reference | Root-level page still contains the older longer reference for older links. |
| Technical asset | Not a prose document that needs translation. |

## P0: release-blocking language entry points

| Topic | Japanese | English | Status | Notes |
|---|---|---|---|---|
| Top-level README | `README.md` | `README.md` | Bilingual summary | Keep short entry content in sync. |
| Docs selector | `docs/README.md` | `docs/README.md` | Compatibility selector | Keep language selector current. |
| Docs index | `docs/ja/README.md` | `docs/en/README.md` | Split | Reading order and maintainer links now point to language-specific docs. |
| Installation | `docs/ja/installation.md` | `docs/en/installation.md` | Split | Keep requirements and asset/importmap guidance in sync. |
| Minimal usage | `docs/ja/minimal-usage.md` | `docs/en/minimal-usage.md` | Split | Keep examples in sync. |
| Usage guide | `docs/ja/usage.md` | `docs/en/usage.md` | Split | Root `docs/usage.md` is a compatibility selector. |
| API overview | `docs/ja/api-overview.md` | `docs/en/api-overview.md` | Split | Keep in sync with API reference docs. |
| API reference | `docs/ja/api.md` | `docs/en/api.md` | Split | Root `docs/api.md` remains as old compatibility reference for now. |
| Public API policy | `docs/ja/public-api.md` | `docs/en/public-api.md` | Split | Root `docs/public-api.md` is a compatibility selector. |
| Release checklist | `docs/ja/release.md` | `docs/en/release.md` | Split | Root `docs/release.md` is a compatibility selector. |

## P1: important feature docs

All P1 feature docs are split under `docs/ja/` and `docs/en/`.

## P2: supporting and maintainer docs

All P2 supporting and maintainer docs are split under `docs/ja/` and `docs/en/`.

## Technical assets

| Asset | Status | Notes |
|---|---|---|
| `docs/mockups/default-tree.html` | Technical asset | No translation needed. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Release readiness documentation checks

Before tagging `v0.1.0`, confirm:

- `docs/ja/README.md` and `docs/en/README.md` point to language-specific user and maintainer docs.
- Root compatibility pages are short language selectors where practical.
- `docs/api.md` is the only known longer root compatibility reference.
- `CHANGELOG.md` includes documentation migration entries.
- New public API changes update both `docs/ja/api.md` and `docs/en/api.md` when practical.

## Remaining cleanup

- Replace root `docs/api.md` with a short language selector when its blob SHA can be retrieved reliably through the GitHub connector or a local git workflow.
- Keep `docs/ja/` and `docs/en/` in sync for future user-facing changes.
