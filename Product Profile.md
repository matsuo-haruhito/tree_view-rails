# Product Profile

## What this repository is

`tree_view` is a Rails gem for rendering parent-child records as tree-style UIs.

The repository is intentionally focused on reusable tree primitives: tree objects, render state, helpers, partials, browser integration hooks, diagnostics, and related documentation. It is not intended to be a complete product application.

## Intended users

This gem is for Rails teams that:

- own the records, routes, queries, and business behavior in a host app
- need reusable tree or tree-table rendering primitives
- want documented boundaries for static, Turbo, and client-side toggle flows
- want optional hooks for selection, lazy loading, windowed rendering, persisted state, and integration diagnostics

## Core value

TreeView gives host apps a shared rendering and interaction foundation without taking over application-specific behavior.

It is a good fit when the host app wants to keep ownership of domain logic while reusing:

- tree traversal and generated path-tree helpers
- render-state-driven row rendering
- reusable row, toolbar, breadcrumb, and diagnostics helpers
- selection, lazy loading, and persisted-state integration hooks
- browser-side controllers and event contracts for TreeView-specific interactions

## Host app responsibilities

The host Rails app remains responsible for:

- CRUD and business actions
- authentication and authorization
- queries, filtering, and pagination strategy
- Turbo Stream responses and fetch timing
- domain-specific validation and error messages
- design system integration and product wording
- app-specific forms, modals, menus, and workflow UI

## Non-goals

This repository does not aim to provide:

- a complete file-manager application
- host-app-specific CRUD screens
- authorization policies
- product-specific context menus or bulk actions
- server-side pagination algorithms
- a full virtual scrolling engine
- sample-app-specific data or seeded showcase behavior

## Integration model

Typical adoption starts with a published gem release:

```ruby
gem "tree_view"
```

When a host app needs unreleased `main` changes, it can opt into the GitHub source explicitly:

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

TreeView is designed so the host app provides the row partial, routes, persistence decisions, and application behavior, while the gem provides the reusable rendering layer and documented extension points.

## Primary documentation entry points

- `README.md` for the short repository overview
- `docs/README.md` for the language selector and maintenance entry point
- `docs/en/README.md` and `docs/ja/README.md` for language-specific documentation trees
- `docs/en/decision-guide.md` and `docs/ja/decision-guide.md` for API selection by use case
- `docs/en/design-policy.md` and `docs/ja/design-policy.md` for responsibility boundaries
- `docs/i18n-audit.md` for ongoing documentation maintenance rules

## Current documentation stance

The top-level README should stay short.

Detailed installation, usage, API, design, troubleshooting, release, and maintenance guidance belongs under `docs/`, with Japanese and English kept in sync when a change affects shared user-facing guidance.
