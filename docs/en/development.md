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
```

For the Rails version matrix:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

## CI policy

Pull requests run the fast Ruby checks that protect day-to-day changes:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`

Pushes to `main` run the broader compatibility and release checks:

- Ruby version matrix
- Rails version matrix
- JavaScript tests
- gem package verification

This keeps pull request feedback focused on Ruby behavior and public API regressions while reserving heavier compatibility and packaging verification for `main` and release decisions.

## Change checklist

### Ruby API changes

- Add or update specs.
- Check `docs/ja/api-overview.md` and `docs/en/api-overview.md`.
- Update `docs/api.md` when needed.
- Update CHANGELOG.

### JavaScript changes

- Run `npm test`.
- Check importmap and packaged files.
- Confirm JavaScript entrypoint compatibility.

### Documentation changes

- Keep Japanese and English docs in sync when practical.
- Update `docs/i18n-audit.md`.
- Decide whether root compatibility docs should remain or point to language-specific docs.

## Before release

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `bundle exec rake build`
- gem package contents
- CHANGELOG
- docs index / i18n audit

## Branch and PR policy

- Keep functional changes small.
- Larger docs-only inventory or split PRs are acceptable.
- PR CI must pass before merge.
- Full compatibility and package verification is confirmed on `main` before release decisions.
