# Release checklist

Before publishing a gem version, check the following items.

## Code and tests

- Run `bundle exec rake`
- Confirm the gem package CI job is green
- Confirm packaged file list specs are green

## Documentation

- Update README when the public usage changes
- Update docs when public options are added
- Update CHANGELOG with user-visible changes

## Gem package

- Bump `TreeView::VERSION`
- Run `gem build tree_view.gemspec`
- Install the generated gem locally
- Confirm `require "tree_view"` works

## Repository

- Tag the released version
- Create a GitHub release when appropriate
