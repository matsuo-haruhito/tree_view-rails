# Release checklist

This page summarizes the release checklist and policy for the `tree_view` gem.

## Versioning policy

`tree_view` follows semantic versioning.

- Patch versions fix bugs or documentation errors without changing public behavior.
- Minor versions add backward-compatible APIs, options, hooks, or docs.
- Major versions may include intentional breaking changes.

Even before `1.0.0`, breaking changes should be deliberate and documented with migration notes in `CHANGELOG.md` and relevant docs.

## Release branch and tag policy

For normal releases, do not create long-lived `release/*` branches. Tag a green commit on `main` with `vX.Y.Z`.

Release flow:

1. Open a release preparation PR against `main`.
2. Update `lib/tree_view/version.rb` when the target version is not already set.
3. Move relevant `CHANGELOG.md` entries from `Unreleased` into a dated version section.
4. Merge the PR into `main`.
5. Confirm main-push full CI is green.
6. Tag the exact green `main` commit with `vX.Y.Z`.
7. Create a GitHub Release when appropriate.
8. Publish the gem when appropriate.

Introduce `release/x.y` branches only when parallel maintenance, long RC verification, or security/compatibility patch lines are needed.

## Initial release target

The initial `0.1.0` release should include a coherent documented baseline rather than every planned feature.

Minimum release conditions:

- `TreeView::VERSION` is set to `0.1.0`
- `CHANGELOG.md` has a dated `0.1.0` section
- core tree construction and rendering helpers are covered by specs
- static rendering works without dedicated JavaScript
- Turbo path-builder integration is documented
- selection params parsing and checkbox rendering are documented when included
- asset and importmap setup is documented
- public API and compatibility boundaries are documented
- package file list includes Rails integration files and docs
- main-push full CI is green

## Code and tests

The committed `package-lock.json` is not yet in sync with `package.json`, so both local setup and CI still use `npm install` for the JavaScript lane. Switch these release checks back to `npm ci` after the lockfile refresh work lands.

Local checks:

```bash
bundle exec rake release:check
bundle exec standardrb
bundle exec rake
npm run test:js
```

`bundle exec rake release:check` validates the current `TreeView::VERSION`, checks for a dated `CHANGELOG.md` section for that version, verifies the gem can be built, confirms release-facing files are packaged, and runs a `bundle exec ruby -Ilib -e 'require "tree_view"'` load check. It skips tag alignment until `vX.Y.Z` exists, then verifies that the release tag points at the current `HEAD`.

Pull request CI checks:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`
- Representative Rails compatibility checks through `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- JavaScript tests through `npm install`, Playwright browser setup, and `npm run test:js`

Main-push CI checks:

- Ruby version matrix
- Rails version matrix
- JavaScript tests through `npm install` and `npm run test:js` until the lockfile is refreshed in sync with `package.json`
- Gem package verification

PR CI must pass before merge. Use the broader `main` CI for release decisions because it includes compatibility matrices, JavaScript coverage, and package verification.

## Documentation

When public usage or public options change, update related docs and CHANGELOG.

When the change touches machine-readable public contract surfaces such as package-root JavaScript exports, controller identifiers, grouped option keys, or documented event names/detail keys, review `config/public_api_manifest.yml` together with the public API docs and any affected feature pages.

- `README.md`
- `docs/ja/README.md`
- `docs/en/README.md`
- `docs/ja/api.md`
- `docs/en/api.md`
- `docs/ja/public-api.md`
- `docs/en/public-api.md`
- `config/public_api_manifest.yml` when it is the source of truth for the changed contract surface
- feature-specific docs
- `docs/i18n-audit.md` (documentation maintenance checklist)
- `CHANGELOG.md`

## CHANGELOG policy

For each release, add a dated entry to `CHANGELOG.md`.

Use these categories:

- Added
- Changed
- Fixed
- Deprecated
- Removed
- Documentation

Include migration notes for breaking changes or deprecations.

## Gem package

Before release:

- Confirm `TreeView::VERSION` matches the release version.
- Run `gem build tree_view.gemspec`.
- Install the generated gem locally and confirm `require "tree_view"` works.
- Confirm packaged files include:
  - `lib/**/*`
  - Rails helpers, views, stylesheets, JavaScript, and importmap files
  - `README.md`
  - `CHANGELOG.md`
  - `docs/**/*`
  - `LICENSE*`

## Repository

- Confirm `main` is green before tagging.
- Tag the released version on `main`.
- Create a GitHub Release when appropriate.
- Link notable closed issues and merged PRs from release notes.
