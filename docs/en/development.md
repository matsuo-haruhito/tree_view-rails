# Development

This page summarizes common development and maintenance tasks for the TreeView gem.

## Setup

```bash
bundle install
npm install
```

With Docker:

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app npm install
```

## Common commands

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm test
npm run test:entrypoints
npm run test:browser
```

For the Rails version matrix:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle exec rake
```

## Public API compatibility specs

Public API compatibility specs protect documented Ruby entry points, helper methods, grouped options, and JavaScript exports from accidental removals or renames. Keep these specs focused on API existence and representative behavior rather than full implementation details.

When an intentional breaking change is accepted, update the public API docs and the compatibility specs together so the documented contract and test coverage stay aligned.

`config/public_api_manifest.yml` is the machine-readable source of truth for the current first slice of documented Ruby module methods, public constants, and helper names. When you add, rename, or remove one of those entries, update the manifest, keep `docs/en/public-api.md` and `docs/ja/public-api.md` aligned, check any README, usage page, or feature doc that names the same surface, add the user-facing note to `CHANGELOG.md`, and review `docs/en/release.md` / `docs/ja/release.md` when release notes or migration expectations need to change.

## JavaScript browser smoke tests

Unit-style JavaScript tests run through Vitest and jsdom with:

```bash
npm test
```

A separate entrypoint smoke check loads `app/javascript/tree_view/index.js` directly:

```bash
npm run test:entrypoints
```

That check keeps the documented controller exports and `registerTreeViewControllers` helper aligned with the importmap entrypoint.

Browser-level smoke tests run through Playwright with:

```bash
npm run test:browser
```

Use the browser smoke suite for representative interaction flows that need a real browser event loop, focus handling, and drag/drop APIs. Keep these tests small and stable: cover keyboard navigation, expand/collapse, checkbox cascade behavior, lazy-loading state changes, transfer payloads, and row form controls coexisting with tree behavior.

When browser-level accessibility smoke is added, do not silently suppress tree or treegrid-oriented findings. If a fixture intentionally allows a pattern because of TreeView's documented table-first policy, leave a short adjacent comment or suppression note that cites `docs/en/accessibility-semantics.md` or `docs/ja/accessibility-semantics.md` and names the specific policy being relied on, such as row-level ARIA on table rows, omitted `aria-controls`, or host-app-owned keyboard flow.

## CI policy

Pull requests run the fast Ruby checks and JavaScript tests that protect day-to-day changes:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`
- Representative Rails compatibility checks through `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- JavaScript entrypoint, unit, and browser smoke tests through `npm run test:js`

Docs-only pull requests that touch only `README.md`, `docs/**`, `Product Profile.md`, `CHANGELOG.md`, and `AGENTS.md` keep the `lint` and `pr_specs` jobs, but short-circuit the representative Rails and JavaScript jobs while preserving the same check names for branch protection. Pull requests that also touch `.github/workflows/**` do not use this shortcut and still run the normal PR lanes.

Pushes to `main` also run the broader compatibility and release checks:

- Ruby version matrix
- Full Rails version matrix
- gem package verification

## Change checklist

### Ruby API changes

- Add or update specs.
- Check `docs/ja/api-overview.md` and `docs/en/api-overview.md`.
- Update public API compatibility specs when documented entry points, helpers, or options are intentionally changed.
- If `config/public_api_manifest.yml` changes, update `docs/en/public-api.md` / `docs/ja/public-api.md`, then review the related README, usage docs, feature docs, `CHANGELOG.md`, and `docs/en/release.md` / `docs/ja/release.md`.
- Update `docs/en/api.md` / `docs/ja/api.md` when needed.
- Update CHANGELOG.

### JavaScript changes

- Run `npm test`.
- Run `npm run test:entrypoints` when documented controller exports or entrypoint wiring changes.
- Run `npm run test:browser` when browser interactions, focus, drag/drop, or real form controls are affected.
- Check importmap and packaged files.
- Confirm JavaScript entrypoint compatibility and update compatibility specs when documented exports intentionally change.

### Documentation changes

- Keep Japanese and English docs in sync when practical.
- Update `docs/i18n-audit.md`.
- Decide whether root compatibility docs should remain or point to language-specific docs.
- When a pull request touches only `README.md`, `docs/**`, `Product Profile.md`, `CHANGELOG.md`, and `AGENTS.md`, confirm that the docs-only CI short-circuit is still the intended policy before relying on it.
- If a pull request also changes `.github/workflows/**`, treat it as a full CI change rather than a docs-only shortcut candidate.

## Before release

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `npm run test:entrypoints`
- `npm run test:browser`
- `bundle exec rake build`
- gem package contents
- confirm `config/public_api_manifest.yml` still matches the documented Ruby / helper entry points and related public API docs
- CHANGELOG
- docs index / i18n audit

## Branch and PR policy

- Keep functional changes small.
- Larger docs-only inventory or split PRs are acceptable.
- PR CI must pass before merge.
- Docs-only PRs may short-circuit the representative Rails and JavaScript jobs, but merge still waits for the named checks to stay green.
- PRs that change workflow definitions should be observed on a fresh head SHA before merge.
- Full compatibility and package verification is confirmed on `main` before release decisions.
