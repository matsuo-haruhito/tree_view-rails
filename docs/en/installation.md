# Installation

This page explains how to install `tree_view` in a Rails host app.

## Requirements

- Ruby 3.2 or later
- Rails 7.0 or later

These requirements should stay aligned with `required_ruby_version` and the `railties` dependency in `tree_view.gemspec`.

## CI coverage

On pull requests, GitHub Actions intentionally runs only lightweight Ruby lint.

On pushes to `main`, full CI runs:

- Ruby spec matrix
- Rails version matrix
- JavaScript tests through `npm ci`
- gem package verification

Release tags should be placed only on `main` commits whose full CI has passed.

## Gemfile

Add the gem to the host app's `Gemfile`.

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

Then run `bundle install` as usual.

```bash
bundle install
```

## CSS import

Import the TreeView CSS from the host app stylesheet.

```scss
@import "tree_view";
```

Example:

```scss
/* app/assets/stylesheets/application.scss */
@import "tree_view";
```

## JavaScript / importmap

Add the TreeView importmap pin when the JavaScript controllers are needed.

```ruby
pin "tree_view", to: "tree_view/index.js"
```

Example:

```ruby
# config/importmap.rb
pin "tree_view", to: "tree_view/index.js"
```

Static rendering works without dedicated TreeView JavaScript. Turbo Stream expand/collapse behavior primarily depends on the host app's Turbo setup and path builders.

JavaScript controllers are used for browser-side integration hooks such as state tracking, keyboard navigation, selection cascade, transfer events, and remote loading state.

## Packaged files

The gem package should include the files needed by Rails host apps:

- `app/assets/stylesheets/tree_view.scss`
- `app/helpers/tree_view_helper.rb`
- `app/helpers/tree_view_helper/**/*`
- `app/javascript/tree_view/**/*`
- `app/views/tree_view/**/*`
- `config/importmap.tree_view.rb`
- `lib/**/*`
- `README.md`
- `CHANGELOG.md`
- `docs/**/*`

When installation behavior changes, keep this list aligned with the packaged file list in `tree_view.gemspec`.

## Propshaft

TreeView can be used with Rails 8 + Propshaft.

The recommended setup is to explicitly import CSS and add the importmap pin from the host app.

```scss
@import "tree_view";
```

```ruby
pin "tree_view", to: "tree_view/index.js"
```

In Propshaft apps, follow the host app's asset loading policy and make the CSS/importmap integration explicit.

## Sprockets

The engine keeps Sprockets-compatible asset hooks.

- Add `app/javascript` to asset paths
- Add `tree_view.css` and `tree_view/index.js` to precompile targets

However, explicit CSS/importmap setup in the host app remains the recommended integration path.

## Asset / importmap audit checklist

When asset or JavaScript paths change, check these items before release:

- `tree_view.gemspec` includes CSS, JavaScript, and importmap files
- README installation examples match this file
- the package checklist in `docs/en/release.md` or `docs/release.md` is updated
- static rendering still works without JavaScript
- JavaScript-dependent features document their importmap pin and data attributes

## Development setup

For local Ruby:

```bash
bundle install
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm install
npm test
```

Rails compatibility Gemfiles live under `gemfiles/`.

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

For Docker:

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app bundle exec rspec
docker compose run --rm app bundle exec rake build
```

Use `.devcontainer/devcontainer.json` for VS Code Dev Containers.

## CI

GitHub Actions runs only `bundle exec standardrb` on pull requests.

On pushes to `main`, GitHub Actions runs Ruby specs, the Rails version matrix, JavaScript tests, and gem package verification.
