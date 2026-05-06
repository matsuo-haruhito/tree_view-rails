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
npm run test:browser
```

For the Rails version matrix:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

## Public API compatibility specs

Public API compatibility specs protect documented Ruby entry points, helper methods, grouped options, and JavaScript exports from accidental removals or renames. Keep these specs focused on API existence and representative behavior rather than full implementation details.

When an intentional breaking change is accepted, update the public API docs and the compatibility specs together so the documented contract and test coverage stay aligned.

## JavaScript browser smoke tests

Unit-style JavaScript tests run through Vitest and jsdom with:

```bash
npm test
```

Browser-level smoke tests run through Playwright with:

```bash
npm run test:browser
```

Use the browser smoke suite for representative interaction flows that need a real browser event loop, focus handling, and drag/drop APIs. Keep these tests small and stable: cover keyboard navigation, expand/collapse, checkbox cascade behavior, lazy-loading state changes, transfer payloads, and row form controls coexisting with tree behavior.

## CI policy

Pull requests run the fast Ruby checks and JavaScript tests that protect day-to-day changes:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`
- JavaScript unit and browser smoke tests through `npm run test:js`

Pushes to `main` also run the broader compatibility and release checks:

- Ruby version matrix
- Rails version matrix
- gem package verification

## Change checklist

### Ruby API changes

- Add or update specs.
- Check `docs/ja/api-overview.md` and `docs/en/api-overview.md`.
- Update public API compatibility specs when documented entry points, helpers, or options are intentionally changed.
- Update `docs/api.md` when needed.
- Update CHANGELOG.

### JavaScript changes

- Run `npm test`.
- Run `npm run test:browser` when browser interactions, focus, drag/drop, or real form controls are affected.
- Check importmap and packaged files.
- Confirm JavaScript entrypoint compatibility and update compatibility specs when documented exports intentionally change.

### Documentation changes

- Keep Japanese and English docs in sync when practical.
- Update `docs/i18n-audit.md`.
- Decide whether root compatibility docs should remain or point to language-specific docs.

## Before release

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `npm run test:browser`
- `bundle exec rake build`
- gem package contents
- CHANGELOG
- docs index / i18n audit

## Branch and PR policy

- Keep functional changes small.
- Larger docs-only inventory or split PRs are acceptable.
- PR CI must pass before merge.
- Full compatibility and package verification is confirmed on `main` before release decisions.
