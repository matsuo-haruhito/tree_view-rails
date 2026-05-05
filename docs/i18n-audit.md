# Documentation i18n audit

This document tracks the documentation language status before the `0.1.0` release.

## Goal

The documentation should be usable by both Japanese and English readers.

For the initial release, the priority is:

1. Make the documentation inventory explicit.
2. Mark which documents are already bilingual, Japanese-first, English-first, or not yet translated.
3. Keep canonical behavior/API descriptions in sync while translations are added.
4. Prioritize user-facing installation, usage, and API documents before maintainer-only process docs.

## Language status labels

| Status | Meaning |
|---|---|
| Bilingual | Japanese and English content are both present enough for practical use. |
| Japanese-first | Japanese is the canonical or more complete version; English should be added or expanded. |
| English-first | English is the canonical or more complete version; Japanese should be added or expanded. |
| Technical asset | Not a prose document that needs translation, such as HTML/CSS mock assets. |

## Translation policy

- Keep code examples identical across languages unless a translated comment is more helpful.
- Prefer one file per topic for now, with Japanese and English sections in the same document, instead of creating separate `ja/` and `en/` trees.
- When behavior changes, update the canonical section first, then update the translated section in the same PR when practical.
- If a PR cannot update both languages, add a short note to this audit or the relevant document so the gap remains visible.
- Prefer translating user-facing documents before maintainer-only documents.

## Priority order

### P0: release-blocking for bilingual readiness

These should be understandable in both Japanese and English before tagging `v0.1.0`.

| Document | Current status | Needed work |
|---|---|---|
| `README.md` | Japanese-first | Add or expand English overview, installation, quick start, and documentation index. |
| `docs/README.md` | Japanese-first | Add English documentation index, reading order, and maintainer/user split. |
| `docs/installation.md` | Needs audit | Ensure both languages cover Gemfile, CSS, importmap, Propshaft/Sprockets, Ruby/Rails requirements. |
| `docs/minimal-usage.md` | Needs audit | Ensure both languages cover the smallest host app setup. |
| `docs/usage.md` | Needs audit | Ensure both languages cover static rendering, Turbo rendering, RenderState, and row partials. |
| `docs/api.md` | Needs audit | Ensure public API descriptions are available in both languages. |
| `docs/public-api.md` | English-first | Add Japanese summary for public/semi-public/internal API policy. |
| `docs/release.md` | English-first | Add Japanese summary for main-tag release policy and release checklist. |

### P1: important feature docs

These should be bilingual soon after P0.

| Document | Current status | Needed work |
|---|---|---|
| `docs/selection.md` | Needs audit | Ensure selection visibility, payload, disabled state, cascade, indeterminate, and max count are bilingual. |
| `docs/lazy-loading.md` | Needs audit | Ensure lazy loading hooks, remote-state events, and children pagination guidance are bilingual. |
| `docs/windowed-rendering.md` | Needs audit | Ensure VisibleRows/RenderWindow/windowed rendering guidance is bilingual. |
| `docs/persisted-state.md` | Needs audit | Ensure generator output and owner-side usage are bilingual. |
| `docs/breadcrumb.md` | Needs audit | Ensure helper usage and builder options are bilingual. |
| `docs/drag-and-drop.md` | Needs audit | Ensure event payload and host app responsibilities are bilingual. |
| `docs/children-pagination.md` | Needs audit | Ensure server-side pagination boundaries are bilingual. |

### P2: supporting and maintainer docs

These can follow after user-facing coverage is in place.

| Document | Current status | Needed work |
|---|---|---|
| `docs/cookbook.md` | Needs audit | Ensure examples and guidance are bilingual. |
| `docs/glossary.md` | Needs audit | Ensure terms map clearly between Japanese and English. |
| `docs/node-keys.md` | Needs audit | Ensure node key collision guidance is bilingual. |
| `docs/tree-diagnostics.md` | Needs audit | Ensure diagnostics APIs and use cases are bilingual. |
| `docs/depth-labels.md` | Needs audit | Ensure builder usage is bilingual. |
| `docs/row-status.md` | Needs audit | Ensure disabled/readonly status guidance is bilingual. |
| `docs/filtered-trees.md` | Needs audit | Ensure filter modes and use cases are bilingual. |
| `docs/rendering-boundaries.md` | Needs audit | Ensure Rails helper/ERB/host app boundary guidance is bilingual. |
| `docs/render-scale.md` | Needs audit | Ensure large tree performance guidance is bilingual. |
| `docs/host-app-extension-points.md` | Needs audit | Ensure extension points are bilingual. |
| `docs/design-policy.md` | Needs audit | Ensure responsibility boundaries are bilingual. |
| `docs/development.md` | Needs audit | Ensure current CI/development workflow is bilingual. |
| `docs/code-quality.md` | Needs audit | Ensure lint/test quality expectations are bilingual. |

### Technical assets

These do not need prose translation unless comments or visible labels become release-facing docs.

| Asset | Status | Notes |
|---|---|---|
| `docs/mockups/default-tree.html` | Technical asset | Visible sample labels may stay as-is unless the mock becomes user-facing localized documentation. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Recommended next PRs

1. Add English sections to `README.md` and `docs/README.md`.
2. Add Japanese summaries to English-first policy docs: `docs/public-api.md` and `docs/release.md`.
3. Add bilingual coverage to `docs/installation.md`, `docs/minimal-usage.md`, `docs/usage.md`, and `docs/api.md`.
4. Work through P1 feature docs in small topic-based PRs.

## Release decision

Do not block all translation work on a single large PR. For `v0.1.0`, the release should at least have bilingual entry points and a visible i18n backlog so readers know which documents are canonical and which translations are pending.
