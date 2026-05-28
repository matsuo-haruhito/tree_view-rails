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
| `docs/mockups/selection-visibility.html` | Technical asset | No translation needed. |
| `docs/mockups/selection-controller-states.html` | Technical asset | No translation needed. |
| `docs/mockups/resource-table-bridge.html` | Technical asset | No translation needed. |
| `docs/mockups/toolbar-actions.html` | Technical asset | No translation needed. |
| `docs/mockups/narrow-sidebar-tree.html` | Technical asset | No translation needed. |
| `docs/mockups/interaction-states.html` | Technical asset | No translation needed. |
| `docs/mockups/children-pagination.html` | Technical asset | No translation needed. |
| `docs/mockups/windowed-rendering.html` | Technical asset | No translation needed. |
| `docs/mockups/filtered-tree-modes.html` | Technical asset | No translation needed. |
| `docs/mockups/empty-state.html` | Technical asset | No translation needed. |
| `docs/mockups/default-tree.css` | Technical asset | No translation needed. |

## Ongoing maintenance

- Keep `docs/ja/` and `docs/en/` in sync for future user-facing changes.
- If a temporary mismatch is unavoidable, leave a visible note and plan the follow-up.
- When `docs/mockups/` gains a new focused reference page, update this technical-assets table and confirm `docs/mockups/README.md` plus `docs/mockups/review-gallery.html` still describe the current set.
- Prefer updating this checklist by replacement when the maintenance rule changes, instead of stacking stale release-specific notes on top of it.
