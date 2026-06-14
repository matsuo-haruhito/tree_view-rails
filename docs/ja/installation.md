# 導入手順

このページは、Rails host app に `tree_view` を導入するための手順です。

## 必要環境

- Ruby 3.2 以上
- Rails 7.0 以上

この条件は `tree_view.gemspec` の `required_ruby_version` と `railties` dependency に合わせます。

## CIで確認している範囲

GitHub Actions では、Pull Requestで以下を実行します。

- Ruby lint: `bundle exec standardrb`
- Ruby specs: `bundle exec rspec`
- representative Rails compatibility checks: `gemfiles/rails_7_0.gemfile`、`gemfiles/rails_7_2.gemfile`、`gemfiles/rails_8_0.gemfile`
- JavaScript tests: `npm install`、Playwright browser setup、`npm run test:js`

`main` へのpushでは、重めの互換性確認とrelease向けchecksを実行します。

- Ruby version matrix
- full Rails version matrix
- `package-lock.json` が `package.json` と同期するまでは、`npm install` と `npm run test:js` による JavaScript tests
- gem package verification

repo には `package-lock.json` を commit していますが、まだ `package.json` と同期が取れていないため、CI は lockfile refresh が済むまで `npm install` を使います。

release tag は、`main` のfull CIが成功したcommitに付けます。

## Gemfile

host app の `Gemfile` に追加します。

公開済み release を使うときは、通常の RubyGems 経路を使います。

```ruby
gem "tree_view"
```

まだ release に入っていない `main` の変更が必要なときだけ、GitHub source を明示します。

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

同梱 stylesheet は、TreeView の再利用可能な構造と軽量な state cue をすぐ確認するための quick-start baseline です。selected、current、collapsed、loading、error、drop target など代表的な row state の見た目は含みますが、最終的な theme、density、brand color、product wording は host app 側の責務です。

host app 側の見た目に合わせる場合も import は残し、TreeView import の後に host app の stylesheet で documented な row / toggle / table selector を上書きしてください。同梱 stylesheet の小さな documented CSS custom property surface は [State cue のスタイリング](styling-state-cues.md) で確認できます。これらの token は state cue color の host-app override guidance であり、complete theme system や manifest-backed Ruby / JavaScript API ではありません。

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

Stimulus application をすでに起動している importmap app では、host app の JavaScript entrypoint から bundled controllers を登録します。

```js
import { application } from "controllers/application"
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

JavaScript-powered な TreeView 機能を使う場合は、quick-start として `registerTreeViewControllers(application)` を使ってください。controller を部分登録したい場合や custom boot order が必要な場合は、public JavaScript surface の `TreeViewControllerIdentifiers` を使えます。詳しくは [Public API](public-api.md#javascript-surface) を参照してください。

## persisted-state setup generator

persisted expansion state を有効にする host app では、gem の導入後に persisted-state install generator を実行します。

```bash
bin/rails generate tree_view:state:install
```

既存の owner model に generated concern を include したい場合は、owner model 名を渡します。

```bash
bin/rails generate tree_view:state:install User
```

generator 名、任意の owner 引数、生成先 path は [Public Setup Surface](public-setup-surface.md) に documented setup surface としてまとめています。この path-level contract は `db/migrate/*_create_tree_view_states.rb`、`app/models/tree_view_state.rb`、`app/models/concerns/tree_view_state_owner.rb` を追跡しますが、migration schema や生成 template 内容そのものを固定するものではありません。生成後のファイルは host app 側で確認し、storage ownership、認可、保存タイミング、cleanup policy、controller action、UI wiring の責務境界は [Persisted State](persisted-state.md) で確認してください。

## Packaged files

TreeView gem package には、Rails host app で必要になる以下を含めます。

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

`config/public_api_manifest.yml` は、documented public surface の machine-readable audit artifact として package に含めます。Rails host app が TreeView を表示するために runtime で読み込む必要はありません。

導入手順を変更した場合は、`tree_view.gemspec` の packaged file list と `script/check_gem_package_contents.rb` の required paths とこの一覧が食い違わないようにします。

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
- `docs/ja/release.md` の package checklist が更新されている
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
npm run test:js
```

ローカル手順も CI と同じく `npm install` を使います。理由は、commit 済みの `package-lock.json` を `npm ci` で安全に使うには、まだ lockfile refresh が必要だからです。`npm run test:js` は CI lane と同じく entrypoint smoke、Vitest suite、Playwright browser smoke をまとめて実行します。

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

GitHub Actions では、Pull Requestで以下を実行します。

- `bundle exec standardrb`
- `bundle exec rspec`
- representative Rails compatibility checks: `gemfiles/rails_7_0.gemfile`、`gemfiles/rails_7_2.gemfile`、`gemfiles/rails_8_0.gemfile`
- JavaScript checks: `npm install`、Playwright browser setup、`npm run test:js`

`main` へのpushでは、Ruby version matrix、full Rails version matrix、JavaScript tests、gem package verificationを実行します。