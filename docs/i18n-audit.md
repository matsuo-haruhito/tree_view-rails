# Documentation maintenance checklist

This page is the long-lived documentation maintenance checklist for `tree_view`.

The path stays at `docs/i18n-audit.md` so existing links keep working, but the document is no longer a pre-`0.1.0` release tracker. Use it as an ongoing checklist when public docs, language-specific docs, release docs, or compatibility guidance change.

## Current structure

Documentation is organized around language-specific directories.

- `docs/README.md`: documentation language selector and maintenance entry point
- `docs/ja/`: Japanese documentation tree
- `docs/en/`: English documentation tree
- `docs/mockups/`: technical mockup assets
- `docs/i18n-audit.md`: documentation maintenance checklist

Root-level prose docs should stay limited to intentional entry points, maintenance notes, or technical assets. Canonical prose docs belong under `docs/ja/` and `docs/en/`.

## Page-level language coverage and translation priority

Use this table when you need a quick answer to "which user-facing pages must stay aligned first?".

Japanese remains the more complete canonical prose source when English wording lags, but the pages below are the current cross-language planning baseline promised by `docs/en/README.md`, `docs/ja/README.md`, and `docs/README.md`.

| Docs lane | Current coverage status | Priority | Maintenance expectation |
|---|---|---|---|
| `docs/README.md`, `docs/en/README.md`, `docs/ja/README.md` | Published entry points for cross-language navigation and language-status guidance | High | Update in the same docs lane whenever reading order, docs map, or language-status promises change |
| `docs/en/installation.md`, `docs/ja/installation.md` | Published in both trees | High | Keep setup, asset, importmap, and first-run instructions aligned before release-facing docs changes land |
| `docs/en/minimal-usage.md`, `docs/ja/minimal-usage.md` | Published in both trees | High | Keep the first working host-app example aligned with installation and usage docs |
| `docs/en/usage.md`, `docs/ja/usage.md` | Published in both trees | High | Keep the baseline user-facing behavior and responsibility guidance aligned |
| `docs/en/api-overview.md`, `docs/ja/api-overview.md` | Published in both trees | High | Keep the first API-orientation page aligned when public entry points or recommended reading order change |
| `docs/en/decision-guide.md`, `docs/ja/decision-guide.md` | Published in both trees | Follow-up | Revisit when API selection guidance or responsibility boundaries change materially |
| `docs/en/faq.md`, `docs/ja/faq.md` and `docs/en/troubleshooting.md`, `docs/ja/troubleshooting.md` | Published in both trees | Follow-up | Revisit when common integration misunderstandings, symptoms, or rescue paths change |
| `docs/en/public-api.md`, `docs/ja/public-api.md`, `docs/en/api.md`, `docs/ja/api.md`, `docs/en/js-events.md`, `docs/ja/js-events.md` | Published in both trees | Follow-up | Revisit in the same PR when public API wording, compatibility promises, or machine-readable public contract surfaces change |
| Feature guides such as `resource-table-bridge.md`, `form-editing.md`, `selection.md`, `lazy-loading.md`, `windowed-rendering.md`, and `persisted-state.md` under both language trees | Published in both trees, but English detail can lag behind Japanese | Follow-up | Revisit when the related feature meaning, host-app responsibility boundary, or recommended pattern changes materially |
| Release-facing and maintainer-facing guides such as `release.md`, `migration.md`, `development.md`, `design-policy.md`, and `code-quality.md` under both language trees | Published in both trees | Follow-up | Revisit when release expectations, compatibility policy, CI workflow, or maintainer rules change |

If a page outside the High lane changes first, do not block the docs PR automatically. Instead, leave a visible note in the changed page or PR and add the follow-up to the next bilingual maintenance sweep.

## When to update both Japanese and English docs

Update both language trees when the change affects user-facing behavior, public options, responsibility boundaries, or guidance that a reader would reasonably expect to match across languages.

Typical triggers:

- public API additions, removals, or compatibility notes
- installation, importmap, JavaScript entrypoint, or asset setup changes
- accessibility semantics, keyboard behavior, or ARIA responsibility changes
- decision-guide recommendations or documented host-app responsibility boundaries
- cookbook, lazy-loading, persisted-state, render-scale, or other feature guidance that changed meaningfully
- migration, deprecation, or release-note guidance for shared public surfaces

If one language must temporarily lag, leave a short note in the changed doc or PR so the mismatch is visible and easy to follow up.

## Update matrix

| Change type | Update these docs |
|---|---|
| Public API, helper entrypoints, option names, compatibility promises, or machine-readable public contract surfaces | `config/public_api_manifest.yml` when it is the machine-readable source of truth, `docs/ja/api.md`, `docs/en/api.md`, `docs/ja/public-api.md`, `docs/en/public-api.md`, and related feature docs |
| Accessibility semantics or interaction behavior | `docs/ja/accessibility-semantics.md`, `docs/en/accessibility-semantics.md`, and any feature docs that describe the affected behavior |
| Installation, importmap, JavaScript entrypoints, packaging, or asset setup | `README.md`, `docs/ja/installation.md`, `docs/en/installation.md`, and `docs/ja/minimal-usage.md` / `docs/en/minimal-usage.md` when first-run examples change |
| Usage recommendations, decision guidance, or responsibility boundaries | `docs/ja/usage.md`, `docs/en/usage.md`, `docs/ja/decision-guide.md`, `docs/en/decision-guide.md`, plus related feature docs |
| Release policy, compatibility policy, migration guidance, or release checklist expectations | `docs/ja/release.md`, `docs/en/release.md`, this checklist, and `CHANGELOG.md` when the public surface changed |
| README-level positioning or top-level docs navigation | `README.md`, `docs/README.md`, `docs/ja/README.md`, and `docs/en/README.md` |

## CHANGELOG guidance

Update `CHANGELOG.md` when the change affects public behavior, public API, release policy, or user-visible documentation that should be called out for adopters.

Typical examples:

- new public helper, class, or documented option
- compatibility policy changes
- installation or packaging changes that affect adopters
- meaningful documentation additions that change how the gem should be integrated

Small typo fixes or local wording cleanups usually do not need a CHANGELOG entry.

## Root-level docs policy

Before adding a new root-level file under `docs/`, check whether it is really an entry point or maintenance asset.

Use a root-level doc only when at least one of these is true:

- it routes readers into both `docs/ja/` and `docs/en/`
- it serves as a cross-language maintenance checklist or project-wide policy note
- it is a technical asset index whose content is naturally language-light

Otherwise, prefer adding the prose doc under both `docs/ja/` and `docs/en/`.

## Release and PR review checklist

Before merging a doc-affecting PR or preparing a release, confirm:

- `README.md`, `docs/README.md`, `docs/ja/README.md`, and `docs/en/README.md` still point to the right entry docs
- Japanese and English docs are updated together when the change affects shared user-facing guidance
- public API changes updated both API docs and public API policy docs when needed
- manifest-backed public contract changes updated `config/public_api_manifest.yml`, both public API docs, and the related feature docs when needed
- compatibility, migration, or deprecation guidance updated both migration guides and release docs when needed
- accessibility changes updated both accessibility docs when needed
- installation or packaging changes updated README and installation docs when needed
- `CHANGELOG.md` was updated when the change materially affects adopters
- root-level docs were not added unless they meet the policy above

## Technical assets

| Asset | Status | Notes |
|---|---|---|
| `docs/mockups/README.md` | Technical asset | Index for static mockup assets. Short bilingual-style prose is acceptable; no separate translation needed. |
| `docs/mockups/review-gallery.html` | Technical asset | Comparison hub for the current static mockup set. No translation needed. |
| `docs/mockups/default-tree.html` | Technical asset | No translation needed. |
| `docs/mockups/resource-table-bridge.html` | Technical asset | No translation needed. |
| `docs/mockups/toolbar-actions.html` | Technical asset | No translation needed. |
| `docs/mockups/narrow-sidebar-tree.html` | Technical asset | No translation needed. |
| `docs/mockups/interaction-states.html` | Technical asset | No translation needed. |
| `docs/mockups/drag-interactive-controls.html` | Technical asset | No translation needed. |
| `docs/mockups/interactive-marker-behaviors.html` | Technical asset | No translation needed. |
| `docs/mockups/windowed-rendering.html` | Technical asset | No translation needed. |
| `docs/mockups/breadcrumb-paths.html` | Technical asset | No translation needed. |
| `docs/mockups/filtered-tree-modes.html` | Technical asset | No translation needed. |
| `docs/mockups/form-editing-rows.html` | Technical asset | No translation needed. |
| `docs/mockups/empty-state.html` | Technical asset | No translation needed. |
| `docs/mockups/row-status-depth-labels.html` | Technical asset | No translation needed. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Ongoing maintenance

- Keep `docs/ja/` and `docs/en/` in sync for future user-facing changes.
- If a temporary mismatch is unavoidable, leave a visible note and plan the follow-up.
- Treat the High lane in the page-level coverage table above as the minimum same-sweep translation set promised by the language READMEs.
- When `docs/mockups/` gains a new focused reference page, update this technical-assets table and confirm `docs/mockups/README.md` plus `docs/mockups/review-gallery.html` still describe the current set.
- Prefer updating this checklist by replacement when the maintenance rule changes, instead of stacking stale release-specific notes on top of it.
