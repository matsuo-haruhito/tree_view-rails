# Installation

This page explains how to install `tree_view` in a Rails host app.

## Requirements

- Ruby 3.2 or later
- Rails 7.0 or later

These requirements should stay aligned with `required_ruby_version` and the `railties` dependency in `tree_view.gemspec`.

## CI coverage

GitHub Actions runs the following checks on pull requests:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`
- Representative Rails compatibility checks through `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- JavaScript tests through `npm install`, Playwright browser setup, and `npm run test:js`

Pushes to `main` keep the heavier compatibility and release checks:

- Ruby version matrix
- Full Rails version matrix
- JavaScript tests through `npm install` and `npm run test:js` until the lockfile is refreshed in sync with `package.json`
- gem package verification

The repository keeps a committed `package-lock.json`, but CI stays on `npm install` until that lockfile is refreshed in sync with `package.json`.

Release tags should be placed only on `main` commits whose full CI has passed.

## Gemfile

Add the gem to the host app's `Gemfile`.

For a published release, use the ordinary RubyGems install path:

```ruby
gem "tree_view"
```

When you need unreleased `main` changes, use the GitHub source explicitly:

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

The packaged stylesheet is a quick-start baseline for TreeView's reusable structure and lightweight state cues. It covers common row states such as selected, current, collapsed, loading, error, and drop target rows, but the final theme, density, brand colors, and product wording remain host-app responsibilities.

When the host app needs a different visual language, keep the import and override the documented row, toggle, and table selectors in the host app stylesheet after the TreeView import. Do not treat the packaged colors as a required public theme API; they are defaults that host apps may replace with their own class selector rules.

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
- `config/locales/**/*`
- `config/public_api_manifest.yml`
- `lib/**/*`
- `README.md`
- `CHANGELOG.md`
- `docs/**/*`

`config/public_api_manifest.yml` is packaged as a machine-readable audit artifact for the documented public surface. Host apps do not need to load it at runtime to render TreeView.

When installation behavior changes, keep this list aligned with the packaged file list in `tree_view.gemspec` and the required paths in `script/check_gem_package_contents.rb`.

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
- the package checklist in `docs/en/release.md` is updated
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
npm run test:js
```

Use `npm install` here for the same reason as CI: the committed `package-lock.json` still needs a refresh before `npm ci` can be trusted. `npm run test:js` runs the entrypoint smoke, Vitest suite, and Playwright browser smoke checks documented in the CI lane.

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

GitHub Actions runs the following on pull requests:

- `bundle exec standardrb`
- `bundle exec rspec`
- representative Rails compatibility checks through `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- JavaScript checks through `npm install`, Playwright browser setup, and `npm run test:js`

On pushes to `main`, GitHub Actions runs the Ruby version matrix, full Rails version matrix, JavaScript tests, and gem package verification.