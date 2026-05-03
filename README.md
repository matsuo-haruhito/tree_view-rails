# tree_view

`tree_view` は、Rails アプリで親子データをツリー表示するためのgemです。

親子関係を持つレコードを、再利用可能なTreeオブジェクト、描画状態、helper、partialとして扱えるようにします。

## 主な機能

- 親子データのツリー化
- 子孫数の集計
- root / children の並び替え
- static表示
- Turbo Stream開閉用path builder
- 異種ノード混在ツリー用 `GraphAdapter`
- 検索結果などから親階層を補完する `PathTree`
- 子ノード起点で親方向へ辿る `ReverseTree`
- viewから使うDOM ID / toggle path / 枝情報helper
- `RenderState` からroot行を描画する `tree_view_rows` helper
- host app側の `row_partial` 差し替え

## 含まないもの

このgemはツリー表示基盤に責務を絞ります。

以下はhost app側で実装します。

- CRUD
- controller / model / form
- 認証・権限管理
- 業務固有の文言やroute
- Turbo Frame modal
- 右クリックメニュー
- demo data / seed

## Installation

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

```bash
bundle install
```

CSSを読み込みます。

```scss
@import "tree_view";
```

必要に応じて importmap に追加します。

```ruby
pin "tree_view", to: "tree_view/index.js"
```

詳しくは [導入手順](docs/installation.md) を参照してください。

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

row partial:

```erb
<!-- app/views/projects/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

詳しくは [使い方](docs/usage.md) を参照してください。

## Documentation

| ドキュメント | 内容 |
|---|---|
| [docs/README.md](docs/README.md) | ドキュメント一覧 |
| [docs/installation.md](docs/installation.md) | 導入手順 |
| [docs/usage.md](docs/usage.md) | 使い方とサンプル |
| [docs/api.md](docs/api.md) | API仕様 |
| [docs/design-policy.md](docs/design-policy.md) | 設計思想と責務範囲 |
| [docs/development.md](docs/development.md) | 開発・保守方針 |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rake build
```

GitHub Actionsでは、`main` へのpushとPull Requestで `bundle exec rake` を実行します。

## License

MIT
