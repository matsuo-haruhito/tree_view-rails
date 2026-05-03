# 導入手順

## 必要環境

- Ruby 3.2 以上
- Rails 7.0 以上

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

## 開発環境

ローカルRubyで実行する場合:

```bash
bundle install
bundle exec rspec
bundle exec rake build
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

GitHub Actions では、`main` へのpushとPull Requestで `bundle exec rake` を実行します。
