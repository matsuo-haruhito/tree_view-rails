# Documentation i18n audit

This document tracks documentation language status before the `0.1.0` release.

## Current structure

Documentation is organized around language-specific directories.

- `docs/README.md`: documentation language selector
- `docs/ja/`: Japanese documentation tree
- `docs/en/`: English documentation tree
- `docs/mockups/`: technical mockup assets
- `docs/i18n-audit.md`: temporary release-readiness tracker

Root-level prose docs have been removed. Canonical prose docs live under `docs/ja/` and `docs/en/`.

## Goal

The documentation should be usable by both Japanese and English readers.

For the initial release, the priority is:

1. Keep the language-specific structure explicit.
2. Keep Japanese and English entry points easy to find.
3. Keep canonical behavior/API descriptions in sync.
4. Prefer language-specific prose docs under `docs/ja/` and `docs/en/`.
5. Keep root-level prose docs out of `docs/` except for intentional entry points.

## Language status labels

| Status | Meaning |
|---|---|
| Split | Separate Japanese and English files exist under `docs/ja/` and `docs/en/`. |
| Entry point | Root-level page intentionally kept as a docs entry point. |
| Technical asset | Not a prose document that needs translation. |

## Entry points

| Path | Status | Notes |
|---|---|---|
| `docs/README.md` | Entry point | Language selector for Japanese and English docs. |
| `docs/i18n-audit.md` | Entry point | Temporary release-readiness tracker. Can be deleted or reduced after the release if it becomes stale. |

## P0: release-blocking language entry points

| Topic | Japanese | English | Status | Notes |
|---|---|---|---|---|
| Top-level README | `README.md` | `README.md` | Split | Bilingual root README points to language-specific docs. |
| Docs selector | `docs/README.md` | `docs/README.md` | Entry point | Keep language selector current. |
| Docs index | `docs/ja/README.md` | `docs/en/README.md` | Split | Reading order and maintainer links point to language-specific docs. |
| Installation | `docs/ja/installation.md` | `docs/en/installation.md` | Split | Keep requirements and asset/importmap guidance in sync. |
| Minimal usage | `docs/ja/minimal-usage.md` | `docs/en/minimal-usage.md` | Split | Keep examples in sync. |
| Usage guide | `docs/ja/usage.md` | `docs/en/usage.md` | Split | Root `docs/usage.md` has been removed. |
| Decision guide | `docs/ja/decision-guide.md` | `docs/en/decision-guide.md` | Split | Keep use-case-to-API guidance, flowchart, and render/data-loading distinctions in sync. |
| API overview | `docs/ja/api-overview.md` | `docs/en/api-overview.md` | Split | Keep in sync with API reference docs. |
| API reference | `docs/ja/api.md` | `docs/en/api.md` | Split | Root `docs/api.md` has been removed. |
| Public API policy | `docs/ja/public-api.md` | `docs/en/public-api.md` | Split | Root `docs/public-api.md` has been removed. |
| Release checklist | `docs/ja/release.md` | `docs/en/release.md` | Split | Root `docs/release.md` has been removed. |

## P1: important feature docs

All P1 feature docs are split under `docs/ja/` and `docs/en/`.

## P2: supporting and maintainer docs

All P2 supporting and maintainer docs are split under `docs/ja/` and `docs/en/`.

Root compatibility selectors for API, usage, public API, release, design policy, development, and code quality have been removed.

## Technical assets

| Asset | Status | Notes |
|---|---|---|
| `docs/mockups/README.md` | Technical asset | Index for static mockup assets. Short bilingual-style prose is acceptable; no separate translation needed. |
| `docs/mockups/default-tree.html` | Technical asset | No translation needed. |
| `docs/mockups/interaction-states.html` | Technical asset | No translation needed. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Release readiness documentation checks

Before tagging `v0.1.0`, confirm:

- `README.md`, `docs/README.md`, `docs/ja/README.md`, and `docs/en/README.md` point to language-specific docs.
- Root-level prose docs have been removed.
- `CHANGELOG.md` includes documentation migration entries.
- New public API changes update both `docs/ja/api.md` and `docs/en/api.md` when practical.

## Remaining cleanup

- Keep `docs/ja/` and `docs/en/` in sync for future user-facing changes.
- Delete or reduce this audit after the release if it becomes stale.
