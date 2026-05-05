# tree_view

`tree_view` は、Rails アプリで親子データをツリー表示するためのgemです。

親子関係を持つレコードを、再利用可能なTreeオブジェクト、描画状態、helper、partialとして扱えるようにします。

`tree_view` is a Rails gem for rendering parent-child records as tree-style UIs.

It provides reusable tree objects, render state, helpers, partials, and browser integration hooks while leaving application-specific CRUD and business actions to the host Rails app.

## 主な機能 / Features

- 親子データのツリー化 / Build trees from parent-child records
- 子孫数の集計 / Count descendants
- root / children の並び替え / Sort root and child items
- static表示 / Static rendering
- Turbo Stream開閉用path builder / Path builders for Turbo Stream expand/collapse actions
- 異種ノード混在ツリー用 `GraphAdapter` / `GraphAdapter` for heterogeneous or graph-like nodes
- 検索結果などから親階層を補完する `PathTree` / `PathTree` for rendering matched nodes with ancestor paths
- 子ノード起点で親方向へ辿る `ReverseTree` / `ReverseTree` for child-to-parent paths
- viewから使うDOM ID / toggle path / 枝情報helper / DOM ID, toggle path, and branch-info helpers for views
- `RenderState` からroot行を描画する `tree_view_rows` helper / `tree_view_rows` helper for rendering root rows from `RenderState`
- 表示対象行の一次元化API `TreeView::VisibleRows` / `TreeView::VisibleRows` for flattening currently visible rows
- 表示対象行を一部だけ描画する `TreeView::RenderWindow` と `tree_view_rows(render_state, window: { offset:, limit: })` / `TreeView::RenderWindow` and opt-in windowed rendering
- host app側の `row_partial` 差し替え / Host-app `row_partial` customization
- 初期展開制御 / Initial expansion controls
  - `initial_state`
  - `expanded_keys`
  - `collapsed_keys`
  - `max_initial_depth`
- 描画範囲制御 / Render scope controls
  - `max_render_depth`
  - `max_leaf_distance`
- 開閉操作範囲制御 / Toggle scope controls
  - `max_toggle_depth_from_root`
  - `max_toggle_leaf_distance`
- 行属性カスタマイズ / Row attribute customization
  - `row_class_builder`
  - `row_data_builder`
- lazy loading hook
  - `load_children_path_builder`
  - `RenderState#lazy_loading`
- checkbox selection
  - JSON payload送信 / JSON payload submission
  - nodeごとのdisabled制御 / Per-node disabled state
  - `selected_keys` による初期選択 / Initial selection through `selected_keys`
  - rendered rows の親子連動チェック / Parent-child cascade for rendered rows
  - indeterminate表示 / Indeterminate state
  - max count制限 / Max-count limit
- persisted state helper / generator
  - `TreeView::PersistedState`
  - `TreeView::StateStore`
  - `rails g tree_view:state:install`
- JavaScript controllers
  - state tracking / keyboard navigation
  - selection collection / cascade / indeterminate
  - drag and drop transfer events
  - remote loading state hooks

## 含まないもの / Out of scope

このgemはツリー表示基盤に責務を絞ります。

This gem focuses on tree rendering primitives.

以下はhost app側で実装します。

Host applications are responsible for:

- CRUD
- controller / model / form
- 認証・権限管理 / authentication and authorization
- 業務固有の文言やroute / application-specific labels and routes
- Turbo Frame modal
- 右クリックメニュー / context menus
- checkbox selection後の削除・移動・関連付けなどの業務処理 / business actions after checkbox selection, such as delete, move, or attach
- server-side children pagination の query / cursor strategy
- infinite scroll / virtual scroll のJavaScript制御 / JavaScript control for infinite scroll or virtual scroll
- demo data / seed

## Installation

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

```bash
bundle install
```

CSSを読み込みます。

Import the CSS:

```scss
@import "tree_view";
```

必要に応じて importmap に追加します。

Add the importmap pin when needed:

```ruby
pin "tree_view", to: "tree_view/index.js"
```

詳しくは [導入手順](docs/installation.md) を参照してください。

See [Installation](docs/installation.md) for details.

## Quick Start

controller:

```ruby
tree = TreeView::Tree.new(
  records: @projects,
  parent_id_method: :parent_project_id
)

@tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: @tree_ui
)
```

view:

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

既存どおり `tree_view/tree_row` partial を直接renderすることもできます。

You can also render the `tree_view/tree_row` partial directly when needed.

row partial:

```erb
<!-- app/views/projects/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

詳しくは [使い方](docs/usage.md) を参照してください。

See [Usage](docs/usage.md) for details.

## Documentation

| ドキュメント / Document | 内容 / Description |
|---|---|
| [docs/README.md](docs/README.md) | ドキュメント一覧 / Documentation index |
| [docs/i18n-audit.md](docs/i18n-audit.md) | 日英対応状況と翻訳優先度 / Documentation language status and translation priority |
| [docs/installation.md](docs/installation.md) | 導入手順 / Installation |
| [docs/minimal-usage.md](docs/minimal-usage.md) | 最小利用例 / Minimal usage |
| [docs/usage.md](docs/usage.md) | 使い方とサンプル / Usage and examples |
| [docs/cookbook.md](docs/cookbook.md) | 既存APIの組み合わせ例 / Cookbook patterns |
| [docs/selection.md](docs/selection.md) | checkbox selection、cascade、indeterminate、max count |
| [docs/lazy-loading.md](docs/lazy-loading.md) | lazy loading hook と children pagination guidance |
| [docs/windowed-rendering.md](docs/windowed-rendering.md) | `VisibleRows` / `RenderWindow` と windowed rendering |
| [docs/persisted-state.md](docs/persisted-state.md) | 開閉状態の保存/復元と generator / Persisted expansion state and generator |
| [docs/api.md](docs/api.md) | API仕様 / API reference |
| [docs/design-policy.md](docs/design-policy.md) | 設計思想と責務範囲 / Design policy and responsibility boundaries |
| [docs/development.md](docs/development.md) | 開発・保守方針 / Development and maintenance |
| [CHANGELOG.md](CHANGELOG.md) | 変更履歴 / Changelog |

## Development

```bash
bundle install
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm install
npm test
```

Rails互換性確認用のGemfileは `gemfiles/` 配下にあります。必要に応じて `BUNDLE_GEMFILE` を指定して実行します。

Rails compatibility Gemfiles are under `gemfiles/`. Set `BUNDLE_GEMFILE` when checking a specific Rails version.

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

GitHub Actionsでは、Pull RequestではRuby lintのみを実行し、`main` へのpushで Ruby spec、Rails version matrix、JavaScript tests、gem package確認を実行します。

GitHub Actions runs lightweight Ruby lint on pull requests. The full Ruby spec matrix, Rails version matrix, JavaScript tests, and gem package verification run on pushes to `main`.

## Release

現在の初期リリース想定versionは `0.1.0` です。

The initial release target is `0.1.0`.

リリース前には以下を確認します。

Before release, check:

- `bundle exec standardrb`
- `bundle exec rspec`
- `bundle exec rake build`
- Rails version matrix CI
- `npm test`
- README / docs / CHANGELOG の整合 / README, docs, and CHANGELOG consistency
- gemspec metadata

## License

MIT
