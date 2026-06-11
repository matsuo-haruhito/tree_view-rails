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

Before writing GitHub Release notes, use the [Release note candidate collector](release-note-candidates.md) to gather merged PR and closed Issue links for maintainer review. The collector is only a checklist aid: it does not rewrite `CHANGELOG.md`, decide the final notes, tag, publish, or create a GitHub Release.

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

`bundle exec rake release:check` validates the current `TreeView::VERSION`, checks for a dated `CHANGELOG.md` section for that version, verifies the gem can be built, confirms release-facing files are packaged, and runs a `bundle exec ruby -Ilib -e 'require "tree_view"'` load check. The main-push `gem_package` CI job additionally runs `ruby script/check_gem_package_contents.rb tree_view-*.gem` against the built gem so representative Rails helper, view partial, locale, docs, JavaScript, CSS, importmap, and public API manifest files remain packaged. Tag alignment is skipped until `vX.Y.Z` exists, then verifies that the release tag points at the current `HEAD`.

Pull request CI checks:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`
- Representative Rails compatibility checks through `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- JavaScript tests through `npm install`, Playwright browser setup, and `npm run test:js`
- Gem package verification when the PR touches package-sensitive paths

Package-sensitive PR paths include `tree_view.gemspec`, `script/check_gem_package_contents.rb`, `.github/workflows/ci.yml`, `lib/**`, Rails integration files under `app/helpers/**`, `app/views/**`, `app/assets/**`, and `app/javascript/**`, plus `config/importmap.tree_view.rb`, `config/public_api_manifest.yml`, and `config/locales/**`. Those PRs run `gem build tree_view.gemspec`, `ruby script/check_gem_package_contents.rb tree_view-*.gem`, `gem install tree_view-*.gem`, and `ruby -e "require 'tree_view'"`. Prose-only docs PRs keep the lighter docs-only behavior unless they also touch one of those package-sensitive paths.

Main-push CI checks:

- Ruby version matrix
- Rails version matrix
- JavaScript tests through `npm install` and `npm run test:js` until the lockfile is refreshed in sync with `package.json`
- Gem package verification, including representative Rails helper, view partial, locale, docs, JavaScript, CSS, importmap, and public API manifest file contents

PR CI must pass before merge. Use the broader `main` CI for release decisions because it includes full compatibility matrices, JavaScript coverage, and unconditional package verification.

## Downstream host-app evidence

TreeView release evidence lives in this repository: the public API manifest, package-root exports, public API and feature docs, mockup README / review gallery, browser smoke targets, and package verification are the upstream sources to review before tagging.

Downstream Rails applications, such as `docs-portal`, should keep their own adoption smoke and rollback notes for app-specific flows such as sidebar trees, detail trees, persisted state, selection, window offsets, routes, permissions, icons, and business row actions. Treat those notes as host-app adoption evidence, not as TreeView's source of truth or a TreeView-only release requirement.

When a downstream smoke fails, first classify whether the finding points to an upstream TreeView contract/package issue or to host-app wiring, query, route, authorization, copy, or rollback policy. Do not use a downstream pinned SHA, application-specific rollback note, or unmerged downstream pull request as the release-facing source of truth for TreeView behavior.

## Documentation

When public usage or public options change, update related docs and CHANGELOG.

When the change touches documented host-app wiring or machine-readable public contract surfaces such as package-root JavaScript exports, controller identifiers, grouped option keys, documented event names/detail keys, documented `data-tree-view-*` integration hooks, or selection controller host-element value attributes, review `config/public_api_manifest.yml` together with the public API docs and any affected feature pages.

`config/public_api_manifest.yml` remains the machine-readable source of truth for package-root exports, controller identifiers, grouped option keys, and documented event detail keys. Public API and feature docs remain the source of truth for documented wiring attributes and hooks that are intentionally not exported there.

For any public API manifest change, confirm the release-facing trail is complete before tagging:

- the manifest change is reflected in `docs/en/public-api.md`, `docs/ja/public-api.md`, and any affected feature page
- `CHANGELOG.md` describes the user-visible compatibility surface under the appropriate release category
- breaking changes, removals, or deprecations include migration notes rather than only manifest or spec wording
- docs-only manifest guidance changes are listed as Documentation entries and do not imply runtime behavior changes

Documentation files to review when public behavior or public compatibility surfaces change:

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

Record public API manifest changes by their user-visible effect. Use Added or Changed for backward-compatible public surface updates, Deprecated or Removed for compatibility changes that require migration notes, and Documentation only when the manifest or docs guidance changed without a runtime contract change.

Include migration notes for breaking changes or deprecations.

## Gem package

Before release:

- Confirm `TreeView::VERSION` matches the release version.
- Run `gem build tree_view.gemspec`.
- Run `ruby script/check_gem_package_contents.rb tree_view-*.gem` against the built gem.
- Install the generated gem locally and confirm `require "tree_view"` works.
- Confirm packaged files include:
  - `lib/**/*`
  - Rails helpers, views, stylesheets, JavaScript, and importmap files
  - `app/helpers/tree_view_helper.rb`
  - `app/views/tree_view/_tree_row.html.erb`
  - `app/javascript/tree_view/index.js`
  - `app/assets/stylesheets/tree_view.scss`
  - `config/importmap.tree_view.rb`
  - `config/public_api_manifest.yml`
  - `config/locales/tree_view.toolbar.en.yml`
  - `config/locales/tree_view.toolbar.ja.yml`
  - `README.md`
  - `CHANGELOG.md`
  - `docs/**/*`
  - `docs/en/release.md`
  - `docs/ja/release.md`
  - `LICENSE*`

## Repository

- Confirm `main` is green before tagging.
- Tag the released version on `main`.
- Create a GitHub Release when appropriate.
- Link notable closed issues and merged PRs from release notes.
