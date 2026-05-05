# Release checklist

Before publishing a gem version, check the following items.

## Versioning policy

`tree_view` follows semantic versioning.

- Patch versions fix bugs or documentation errors without changing public behavior.
- Minor versions may add backward-compatible public APIs, options, hooks, and docs.
- Major versions may include intentional breaking changes.

While the gem is still before `1.0.0`, breaking changes may happen in minor versions, but they should still be treated as deliberate compatibility decisions:

- document the migration path in `CHANGELOG.md`
- update `docs/public-api.md` when the public surface changes
- prefer compatibility shims when the maintenance cost is small

## Release branch and tag policy

`main` is the release source of truth.

By default, releases are managed by Git tags on `main`, not long-lived release branches.

Recommended tag format:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The release flow is:

1. Open a release preparation PR against `main`.
2. Update `lib/tree_view/version.rb`.
3. Move relevant `CHANGELOG.md` entries from `Unreleased` into a dated version section.
4. Merge the release preparation PR into `main`.
5. Confirm the main-push full CI is green.
6. Tag the exact green `main` commit with `vX.Y.Z`.
7. Create a GitHub Release from that tag when appropriate.
8. Publish the gem when appropriate.

Do not create a `release/*` branch for normal patch or minor releases.

Introduce a `release/x.y` branch only when parallel maintenance is needed, for example:

- `main` is already accepting breaking changes for the next line.
- an older minor line needs a bugfix release.
- a release candidate must be frozen for an extended verification window.
- multiple supported release lines need security or compatibility patches.

When release branches are introduced, document the branch policy in this file and keep tag names globally unique.

## Initial release target

The initial `0.1.0` release should include a coherent, documented baseline rather than every planned feature.

Minimum release conditions:

- core tree construction and rendering helpers are covered by specs
- static rendering works without dedicated JavaScript
- Turbo path-builder integration is documented
- selection params parsing and checkbox rendering are documented when included
- asset and importmap setup is documented
- public API and compatibility boundaries are documented
- package file list includes Rails integration files and docs
- `bundle exec rake` is green in CI

Issues that add optional UX enhancements, large-tree strategies, or richer browser events can be released later as minor versions.

## Code and tests

Local checks:

- Run `bundle exec standardrb`
- Run `bundle exec rake`
- Run `bundle exec rake build`
- Run `npm test`

Main-push CI checks:

- Ruby spec matrix is green.
- Rails version matrix is green.
- JavaScript tests are green through `npm ci`.
- Gem package verification is green.

Pull request CI is intentionally lightweight and currently runs Ruby lint only. Do not treat a pull request green check as a full release verification. The release tag should be placed only after the merge commit on `main` has completed full CI successfully.

Confirm the supported Ruby / Rails versions in `docs/installation.md` match `tree_view.gemspec` and the Rails matrix Gemfiles.

## Documentation

- Update README when the public usage changes
- Update docs when public options are added
- Update `docs/public-api.md` when the public surface changes
- Update `docs/installation.md` when asset, importmap, Ruby, or Rails requirements change
- Update CHANGELOG with user-visible changes

## CHANGELOG policy

For each release, add a dated entry to `CHANGELOG.md` with these groups when relevant:

- Added
- Changed
- Fixed
- Deprecated
- Removed
- Documentation

Include migration notes for breaking changes or deprecations.

Before tagging, `CHANGELOG.md` should not leave release-bound user-visible changes only under `Unreleased`. Move them into the released version section.

## Gem package

- Bump `TreeView::VERSION`
- Run `gem build tree_view.gemspec`
- Install the generated gem locally
- Confirm `require "tree_view"` works
- Confirm packaged files include:
  - `lib/**/*`
  - Rails helpers, views, stylesheets, JavaScript, and importmap files
  - `README.md`
  - `CHANGELOG.md`
  - `docs/**/*`
  - `LICENSE*`

## Asset, importmap, and npm audit

Before release, confirm the installation guide still matches the packaged files.

- `app/assets/stylesheets/tree_view.scss` is packaged
- `app/javascript/tree_view/**/*` is packaged
- `config/importmap.tree_view.rb` is packaged
- README and `docs/installation.md` show the recommended CSS import
- README and `docs/installation.md` show the recommended importmap pin
- Sprockets / Propshaft notes do not promise behavior that is not covered by the gem package
- `package-lock.json` is committed when `package.json` changes
- JavaScript CI uses `npm ci`, so lockfile updates should be part of dependency update PRs

## Repository

- Ensure `main` is green before tagging
- Tag the released version on `main`
- Create a GitHub release when appropriate
- Link notable closed issues and merged PRs from the release notes
