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
2. Explicit decisions in the relevant issue and pull request
3. Durable docs under `docs/en/` and `docs/ja/`
4. Entry-point summaries in `README.md`, `docs/README.md`, and `AGENTS.md`

## What TreeView owns

- Tree traversal and structure helpers
- Render state and row rendering helpers
- Generic UI configuration builders and hooks
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

## Recommended first reads

For maintainers making changes, start in this order:

1. `AGENTS.md` for repository-specific workflow and documentation update rules
2. `README.md` for public positioning and quick entry points
3. `docs/README.md` for the docs map
4. `docs/en/README.md` or `docs/ja/README.md` for language-specific docs
5. `docs/en/design-policy.md` or `docs/ja/design-policy.md` for responsibility boundaries
