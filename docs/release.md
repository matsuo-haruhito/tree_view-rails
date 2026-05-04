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

- Run `bundle exec rake`
- Run `bundle exec rake build`
- Confirm the gem package CI job is green when available
- Confirm packaged file list specs are green when available
- Confirm the supported Ruby / Rails versions in `docs/installation.md` match `tree_view.gemspec`

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

## Asset and importmap audit

Before release, confirm the installation guide still matches the packaged files.

- `app/assets/stylesheets/tree_view.scss` is packaged
- `app/javascript/tree_view/**/*` is packaged
- `config/importmap.tree_view.rb` is packaged
- README and `docs/installation.md` show the recommended CSS import
- README and `docs/installation.md` show the recommended importmap pin
- Sprockets / Propshaft notes do not promise behavior that is not covered by the gem package

## Repository

- Ensure `main` is green before tagging
- Tag the released version
- Create a GitHub release when appropriate
- Link notable closed issues and merged PRs from the release notes
