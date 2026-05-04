# AGENTS.md

see `/mnt/c/work/AGENTS.md`

## Purpose

This repository contains the `tree_view` Ruby gem for Rails.

`tree_view` provides reusable tree rendering primitives for Rails host applications. It should stay focused on tree structure, render state, view helpers, partials, and Rails integration points.

Do not use `context.md`. Repository context is maintained here and in `docs/`.

## First Read

Before making changes, read these files in this order:

1. `AGENTS.md`
2. `README.md`
3. `docs/README.md`
4. The relevant document under `docs/`
5. The implementation files related to the task

Use `docs/` as the durable documentation source:

- `docs/design-policy.md` — design intent, responsibility boundaries, include/exclude policy
- `docs/installation.md` — installation and asset/importmap setup
- `docs/usage.md` — usage examples
- `docs/api.md` — public API reference
- `docs/development.md` — development, CI, and documentation update rules

## Repository Scope

Keep this repository dedicated to the gem body.

Allowed scope:

- `lib/tree_view*`
- `tree_view.gemspec`
- `app/helpers/tree_view_helper.rb`
- `app/views/tree_view/*`
- `app/assets/stylesheets/tree_view.scss`
- `app/javascript/tree_view/*`
- `config/importmap.tree_view.rb`
- specs, README, and docs for the gem

Out of scope:

- sample app controllers, models, views, and forms
- host-app-specific CRUD
- host-app-specific route names or business wording
- authentication and authorization logic
- Turbo Frame modal implementation
- right-click menu implementation
- seed data, screenshots, demo data, and app-specific database setup

## Design Rules

- Keep `TreeView` core focused on tree logic and thin rendering integration.
- Keep `UiConfig` / `UiConfigBuilder` generic.
- Keep `row_partial` as a public extension point owned by the host app.
- Do not make Turbo behavior mandatory; static rendering must remain supported.
- Do not reintroduce sample-app-specific code.
- Preserve public API compatibility unless the user explicitly asks for a breaking change.
- Prefer small, focused changes.

Current durable decisions:

- `initial_state` priority is `RenderState > global config > :expanded`.
- `tree_toggle_all_path(state:)` is the primary API for global toggle paths.
- `tree_expand_all_path` and `tree_collapse_all_path` are convenience helpers.
- Global toggle scope is currently `all`.
- Branch rendering information is calculated in helper logic from the tree.
- `row_partial` must be provided by the host app.
- Toggle mode is `:static` or `:turbo`.
- Root and children ordering is centralized through `TreeView::Tree#sort_items` and `sorter:`.
- The default sorter is descendant count ascending.

## Documentation Rules

When behavior, public API, setup steps, or design intent changes, update the relevant docs.

- User-facing overview: `README.md`
- Detailed docs index: `docs/README.md`
- Design decisions: `docs/design-policy.md`
- Installation changes: `docs/installation.md`
- Usage changes: `docs/usage.md`
- API changes: `docs/api.md`
- Development and CI changes: `docs/development.md`

Keep `README.md` short. Put detailed setup, examples, and API contracts in `docs/`.

Do not recreate `context.md`.

## Testing

For implementation changes, run or preserve compatibility with:

```bash
bundle exec rspec
bundle exec rake
bundle exec rake build
```

GitHub Actions runs `bundle exec rake` on pull requests and pushes to `main`.

## Issue / Work Item Guidance

Open GitHub Issues are the source of planned feature work.

Important planned feature areas include:

- path tree from child nodes to normal root-oriented display
- reverse tree display from child to parent
- orphan node handling
- node-level initial expansion state
- row class / data attribute builders
- initial max depth rendering
- node key / DOM ID collision detection
- RenderState rendering helper
- sorter return value validation

Do not implement large feature areas opportunistically while working on unrelated tasks.

## Codex Common Operation

- Inherit the common skill definitions described in the root [AGENTS.md](/mnt/c/work/AGENTS.md), even when Codex is launched directly in this repository.
- Keep repository-specific context in this local `AGENTS.md` and durable docs in `docs/`.
