# 導入手順 / Installation

このページは、Rails host app に `tree_view` を導入するための手順です。

This page explains how to install `tree_view` in a Rails host app.

## 必要環境 / Requirements

- Ruby 3.2 以上 / Ruby 3.2 or later
- Rails 7.0 以上 / Rails 7.0 or later

この条件は `tree_view.gemspec` の `required_ruby_version` と `railties` dependency に合わせます。

These requirements should stay aligned with `required_ruby_version` and the `railties` dependency in `tree_view.gemspec`.

## CIで確認している範囲 / CI coverage

GitHub Actions では、Pull Requestでは軽量なRuby lintのみを実行します。

On pull requests, GitHub Actions intentionally runs only lightweight Ruby lint.

`main` へのpushでは、以下のfull CIを実行します。

On pushes to `main`, full CI runs:

- Ruby spec matrix
- Rails version matrix
- JavaScript tests through `npm ci`
- gem package verification

release tag は、`main` のfull CIが成功したcommitに付けます。

Release tags should be placed only on `main` commits whose full CI has passed.

## Gemfile

host app の `Gemfile` に追加します。

Add the gem to the host app's `Gemfile`.

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

その後、通常どおり bundle install します。

Then run `bundle install` as usual.

```bash
bundle install
```

## CSSの読み込み / CSS import

host app 側の stylesheet で TreeView 用CSSを読み込みます。

Import the TreeView CSS from the host app stylesheet.

```scss
@import "tree_view";
```

例 / Example:

```scss
/* app/assets/stylesheets/application.scss */
@import "tree_view";
```

## JavaScript / importmap

必要に応じて importmap に TreeView 用のpinを追加します。

Add the TreeView importmap pin when the JavaScript controllers are needed.

```ruby
pin "tree_view", to: "tree_view/index.js"
```

例 / Example:

```ruby
# config/importmap.rb
pin "tree_view", to: "tree_view/index.js"
```

現在のTreeViewは、static表示だけであれば専用JavaScriptなしでも利用できます。Turbo Streamで開閉を行う場合も、host app側のTurbo構成とpath builderが中心になります。

Static rendering works without dedicated TreeView JavaScript. Turbo Stream expand/collapse behavior primarily depends on the host app's Turbo setup and path builders.

JavaScript controllers are used for browser-side integration hooks such as state tracking, keyboard navigation, selection cascade, transfer events, and remote loading state.

## Packaged files

TreeView gem package には、Rails host app で必要になる以下を含めます。

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

導入手順を変更した場合は、`tree_view.gemspec` の packaged file list とこの一覧が食い違わないようにします。

When installation behavior changes, keep this list aligned with the packaged file list in `tree_view.gemspec`.

## Propshaft

Rails 8 + Propshaft でも利用できます。

TreeView can be used with Rails 8 + Propshaft.

最低限、host app 側から CSS / importmap を明示的に読み込む構成を推奨します。

The recommended setup is to explicitly import CSS and add the importmap pin from the host app.

```scss
@import "tree_view";
```

```ruby
pin "tree_view", to: "tree_view/index.js"
```

Propshaft 環境では、host app 側の asset 読み込み方針に合わせて、上記のCSSとimportmap pinを明示する運用を基本にします。

In Propshaft apps, follow the host app's asset loading policy and make the CSS/importmap integration explicit.

## Sprockets

Engine側にはSprockets互換のasset hookを残しています。

The engine keeps Sprockets-compatible asset hooks.

- `app/javascript` を asset paths に追加 / Add `app/javascript` to asset paths
- `tree_view.css` / `tree_view/index.js` を precompile 対象に追加 / Add `tree_view.css` and `tree_view/index.js` to precompile targets

ただし、導入の中心はhost app側でCSS / importmapを明示的に読み込む運用です。

However, explicit CSS/importmap setup in the host app remains the recommended integration path.

## Asset / importmap audit checklist

asset または JavaScript の配置を変更した場合は、release 前に以下を確認します。

When asset or JavaScript paths change, check these items before release:

- `tree_view.gemspec` がCSS、JavaScript、importmapファイルを含んでいる / `tree_view.gemspec` includes CSS, JavaScript, and importmap files
- README の導入例がこのファイルと一致している / README installation examples match this file
- `docs/release.md` の package checklist が更新されている / the package checklist in `docs/release.md` is updated
- static表示がJavaScriptなしでも利用できる、という前提を壊していない / static rendering still works without JavaScript
- JavaScriptが必要な機能は、必要なimportmap pinやdata属性をdocsに書いている / JavaScript-dependent features document their importmap pin and data attributes

## 開発環境 / Development setup

ローカルRubyで実行する場合:

For local Ruby:

```bash
bundle install
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm install
npm test
```

Rails互換性確認用のGemfileは `gemfiles/` 配下にあります。

Rails compatibility Gemfiles live under `gemfiles/`.

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

Dockerで実行する場合:

For Docker:

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app bundle exec rspec
docker compose run --rm app bundle exec rake build
```

VS Code Dev Containersを使う場合は `.devcontainer/devcontainer.json` を利用できます。

Use `.devcontainer/devcontainer.json` for VS Code Dev Containers.

## CI

GitHub Actions では、Pull Requestでは `bundle exec standardrb` のみを実行します。

GitHub Actions runs only `bundle exec standardrb` on pull requests.

`main` へのpushでは、Ruby spec、Rails version matrix、JavaScript tests、gem package verificationを実行します。

On pushes to `main`, GitHub Actions runs Ruby specs, the Rails version matrix, JavaScript tests, and gem package verification.
