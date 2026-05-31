# Product Profile

## What this repository is

`tree_view` is a Rails gem for reusable tree-style UI primitives.

It packages tree traversal, render state, helpers, partials, CSS baseline, and JavaScript controllers that host Rails apps can compose into tree and tree-table screens.

## Who this is for

- Maintainers evolving the gem
- Host-app developers integrating TreeView into Rails apps
- Reviewers checking whether a change belongs in the gem or in the host app

## Source of truth

When implementation and docs drift, use this order:

1. Current code in `lib/`, `app/helpers/`, `app/views/`, `app/assets/`, and `app/javascript/`
2. Machine-readable public API contracts in `config/public_api_manifest.yml` and the compatibility checks that read them
3. Explicit decisions in the relevant issue and pull request
4. Durable docs under `docs/`, especially the relevant guides in `docs/en/` and `docs/ja/`
5. Entry-point summaries in `README.md`, `docs/README.md`, `AGENTS.md`, and this profile

Treat `CHANGELOG.md` as a release-facing summary of shipped public changes, not as the primary source for current behavior.

## What TreeView owns

- Tree traversal and structure helpers
- Render state and row rendering helpers
- Generic UI configuration builders and hooks
- Public API compatibility manifests and checks for documented helpers, grouped options, and JavaScript entrypoints
- Selection, lazy loading, windowed rendering, persisted state, and diagnostics
- Bundled CSS baseline and JavaScript controller entrypoints that support those primitives
- Documentation for public APIs and responsibility boundaries

## What host apps own

- CRUD, authorization, and business actions
- Queries, filtering, server-side pagination, and data-loading reduction
- Routes, labels, domain language, and design system integration
- Turbo Stream responses, modals, menus, and app-specific workflows
- Final row content rendered through host-app partials and builders

## Non-goals

- A complete file-manager or admin product UI
- Host-app-specific controller and view implementations
- Finished domain workflows, bulk actions, or context menus
- A full virtual scrolling engine or host-app query planner
- Demo app business logic or seed data as part of the gem's public contract

## Maintainer companion docs

Use these durable entry points together when you are checking scope, docs sync, or release-facing changes:

- `AGENTS.md` for repository workflow and documentation update rules
- `README.md` for public positioning and quick entry points
- `docs/README.md` for the cross-language docs map and maintainer entry points
- `docs/en/README.md` or `docs/ja/README.md` for language-specific docs navigation
- `docs/i18n-audit.md` for cross-language maintenance rules and docs update coverage
- `docs/en/release.md` or `docs/ja/release.md` for release checklist, release consistency checks, and changelog expectations
- `config/public_api_manifest.yml` for machine-readable public API contracts that specs and entrypoint smoke checks compare against current code
- `CHANGELOG.md` for shipped public changes, compatibility notes, and notable docs additions

## Recommended first reads

For maintainers making changes, start in this order:

1. `AGENTS.md` for repository-specific workflow and documentation update rules
2. `README.md` for public positioning and quick entry points
3. `docs/README.md` for the docs map and maintainer entry points
4. `docs/en/README.md` or `docs/ja/README.md` for language-specific docs navigation
5. `docs/en/design-policy.md` or `docs/ja/design-policy.md` for responsibility boundaries
6. `docs/i18n-audit.md` when the task changes public docs or language coverage
7. `config/public_api_manifest.yml` when the task changes documented helper methods, grouped options, JavaScript entrypoints, controller identifiers, or event contracts
8. `docs/en/release.md` or `docs/ja/release.md` when the task affects release-facing docs, compatibility notes, or package verification workflow
9. `CHANGELOG.md` when the task affects release-facing public behavior or compatibility notes
