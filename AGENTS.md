# AGENTS.md

Repository-specific maintainer guidance for `tree_view`.
Use this file together with `README.md`, `docs/README.md`, `Product Profile.md`, and `CHANGELOG.md`.

## Purpose

This repository contains the `tree_view` Ruby gem for Rails.

`tree_view` provides reusable tree rendering primitives for Rails host applications. It should stay focused on tree structure, render state, view helpers, partials, and Rails integration points.

Do not use `context.md`. Repository context is maintained here and in `docs/`.

## First Read

Before making changes, read these files in this order:

1. `AGENTS.md`
2. `README.md`
3. `docs/README.md`
4. `Product Profile.md`
5. The relevant document under `docs/en/` or `docs/ja/`
6. The implementation files related to the task

When the task touches documentation structure or bilingual coverage, also read `docs/i18n-audit.md`.

When the task touches release-facing behavior, compatibility notes, or notable documentation additions, also read `CHANGELOG.md`.

Use these files as the durable documentation source:

- `README.md` — public positioning and short entry point
- `Product Profile.md` — repository positioning, source-of-truth order, host-app responsibilities, and non-goals
- `docs/README.md` — language selector and maintenance entry point
- `docs/en/design-policy.md` / `docs/ja/design-policy.md` — design intent, responsibility boundaries, include/exclude policy
- `docs/en/installation.md` / `docs/ja/installation.md` — installation and asset/importmap setup
- `docs/en/usage.md` / `docs/ja/usage.md` — usage examples
- `docs/en/api.md` / `docs/ja/api.md` — public API reference
- `docs/en/development.md` / `docs/ja/development.md` — development, CI, and documentation update rules
- `docs/en/release.md` / `docs/ja/release.md` — release checklist, changelog expectations, and compatibility-note policy
- `CHANGELOG.md` — release-facing summary of public changes, compatibility notes, and notable documentation additions
- `docs/i18n-audit.md` — documentation maintenance checklist

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
- Toggle mode is `:static`, `:turbo`, or `:client`.
- Root and children ordering is centralized through `TreeView::Tree#sort_items` and `sorter:`.
- The default sorter is descendant count ascending.

## Documentation Rules

When behavior, public API, setup steps, or design intent changes, update the relevant docs.

- User-facing overview: `README.md`
- Detailed docs index: `docs/README.md`
- Maintainer entry-point or source-of-truth guidance: `AGENTS.md`, `Product Profile.md`, and `CHANGELOG.md` when release-facing expectations or notable documentation additions changed
- Design decisions: `docs/en/design-policy.md` and `docs/ja/design-policy.md`
- Installation changes: `docs/en/installation.md` and `docs/ja/installation.md`
- Usage changes: `docs/en/usage.md` and `docs/ja/usage.md`
- API changes: `docs/en/api.md` and `docs/ja/api.md`
- Development and CI changes: `docs/en/development.md` and `docs/ja/development.md`
- Cross-language maintenance rules: `docs/i18n-audit.md`
- When `config/public_api_manifest.yml` changes, also review `docs/en/public-api.md`, `docs/ja/public-api.md`, the affected usage or feature docs, `CHANGELOG.md`, and `docs/en/release.md` / `docs/ja/release.md` when release notes or migration expectations need to change

Keep `README.md` short. Put detailed setup, examples, and API contracts in `docs/`.

Do not recreate `context.md`.

## Testing

For implementation changes, run or preserve compatibility with:

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm test
npm run test:entrypoints
npm run test:browser
```

GitHub Actions runs the following on pull requests:

- `bundle exec standardrb`
- `bundle exec rspec`
- representative Rails compatibility checks via `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- `npm run test:js`

Docs-only pull requests that touch only `README.md`, `docs/**`, `Product Profile.md`, `CHANGELOG.md`, and `AGENTS.md` keep the `lint` and `pr_specs` jobs, but short-circuit the representative Rails lanes while preserving the same check names for branch protection. The JavaScript job also short-circuits for docs-only pull requests unless `docs/mockups/**` changed; mockup changes still check out the branch, install Playwright, and run `npm run test:browser`. Pull requests that touch `test/browser/**` are not docs-only; the JavaScript job checks out the branch, installs Playwright, and runs `npm run test:browser` so browser smoke spec changes get fresh evidence. Pull requests that also touch `.github/workflows/**` do not use this shortcut and still run the normal PR lanes.

Pushes to `main` also run the broader compatibility and release checks:

- Ruby version matrix
- full Rails version matrix
- gem package verification

## Issue / Work Item Guidance

Open GitHub Issues are the source of planned feature work.

Use the current issue body, PR description, README, and language-specific docs as the source of truth for planned work rather than relying on stale example lists in this file.

Do not implement large feature areas opportunistically while working on unrelated tasks.

## Codex Common Operation

- Use this local `AGENTS.md` as the repository-specific operating contract.
- Prefer repository-local durable docs when you need broader context: `README.md`, `docs/README.md`, `Product Profile.md`, `CHANGELOG.md`, and the relevant language-specific docs under `docs/`.
- Keep repository-specific context in this local `AGENTS.md` and durable docs in `docs/`.