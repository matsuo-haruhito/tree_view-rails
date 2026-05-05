# 導入手順

このページは、Rails host app に `tree_view` を導入するための手順です。

## 必要環境

- Ruby 3.2 以上
- Rails 7.0 以上

この条件は `tree_view.gemspec` の `required_ruby_version` と `railties` dependency に合わせます。

## CIで確認している範囲

GitHub Actions では、Pull Requestでは軽量なRuby lintのみを実行します。

`main` へのpushでは、以下のfull CIを実行します。

- Ruby spec matrix
- Rails version matrix
- JavaScript tests through `npm ci`
- gem package verification

release tag は、`main` のfull CIが成功したcommitに付けます。

## Gemfile

host app の `Gemfile` に追加します。

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

その後、通常どおり bundle install します。

```bash
bundle install
```

## CSSの読み込み

host app 側の stylesheet で TreeView 用CSSを読み込みます。

```scss
@import "tree_view";
```

例:

```scss
/* app/assets/stylesheets/application.scss */
@import "tree_view";
```

## JavaScript / importmap

必要に応じて importmap に TreeView 用のpinを追加します。

```ruby
pin "tree_view", to: "tree_view/index.js"
```

例:

```ruby
# config/importmap.rb
pin "tree_view", to: "tree_view/index.js"
```

現在のTreeViewは、static表示だけであれば専用JavaScriptなしでも利用できます。Turbo Streamで開閉を行う場合も、host app側のTurbo構成とpath builderが中心になります。

JavaScript controllers は、state tracking、keyboard navigation、selection cascade、transfer events、remote loading stateなどのbrowser-side integration hookで使います。

## Packaged files

TreeView gem package には、Rails host app で必要になる以下を含めます。

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

## Propshaft

Rails 8 + Propshaft でも利用できます。

最低限、host app 側から CSS / importmap を明示的に読み込む構成を推奨します。

```scss
@import "tree_view";
```

```ruby
pin "tree_view", to: "tree_view/index.js"
```

## Sprockets

Engine側にはSprockets互換のasset hookを残しています。

- `app/javascript` を asset paths に追加
- `tree_view.css` / `tree_view/index.js` を precompile 対象に追加

ただし、導入の中心はhost app側でCSS / importmapを明示的に読み込む運用です。

## Asset / importmap audit checklist

asset または JavaScript の配置を変更した場合は、release 前に以下を確認します。

- `tree_view.gemspec` がCSS、JavaScript、importmapファイルを含んでいる
- README の導入例がこのファイルと一致している
- `docs/ja/release.md` または `docs/release.md` の package checklist が更新されている
- static表示がJavaScriptなしでも利用できる、という前提を壊していない
- JavaScriptが必要な機能は、必要なimportmap pinやdata属性をdocsに書いている

## 開発環境

ローカルRubyで実行する場合:

```bash
bundle install
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm install
npm test
```

Rails互換性確認用のGemfileは `gemfiles/` 配下にあります。

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

Dockerで実行する場合:

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app bundle exec rspec
docker compose run --rm app bundle exec rake build
```

VS Code Dev Containersを使う場合は `.devcontainer/devcontainer.json` を利用できます。

## CI

GitHub Actions では、Pull Requestでは `bundle exec standardrb` のみを実行します。

`main` へのpushでは、Ruby spec、Rails version matrix、JavaScript tests、gem package verificationを実行します。
