# tree_view

`tree_view` は Rails アプリで親子データをツリー表示するための gem です。  
このリポジトリは GEM 本体専用で、旧 sample app 由来の CRUD や demo 画面は含みません。

## 含むもの

- `TreeView::Tree`
  - 親子解決
  - 子孫数集計
  - ルート並び替え
- `TreeView::Traversal`
  - 子孫 ID 収集
- `TreeView::GraphAdapter`
  - 異種ノード混在ツリーの接続
- `TreeView::RenderState`
  - 画面単位の描画状態
- `TreeView::UiConfig` / `TreeView::UiConfigBuilder`
  - DOM ID と path helper の注入
- `TreeViewHelper`
  - view から使う補助 helper
- `app/views/tree_view/*`
  - ツリー行描画 partial
- `app/assets/stylesheets/tree_view.scss`
  - 基本スタイル

## 含まないもの

- sample app の controller / model / view
- Turbo Stream の統合例
- CRUD
- Turbo Frame modal
- 右クリックメニュー
- seed / screenshot / Docker 構成

## Installation

`Gemfile`:

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

host app 側で TreeView 用の stylesheet を読み込みます。

```scss
@import "tree_view";
```

必要なら importmap に TreeView 用 pin を追加します。

```ruby
pin "tree_view", to: "tree_view/index.js"
```

### Propshaft

Rails 8 + Propshaft でも使えます。最低限、host app 側で stylesheet と importmap を読み込めれば十分です。

`app/assets/stylesheets/application.scss`:

```scss
@import "tree_view";
```

`config/importmap.rb`:

```ruby
pin "tree_view", to: "tree_view/index.js"
```

現在の engine 側 asset hook は Sprockets 互換も残していますが、導入の中心は「host app 側から CSS / importmap を明示的に読む」前提です。

## Usage

### Tree

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id
)
```

### UiConfig

```ruby
tree_ui = TreeView::UiConfigBuilder.new(context: view_context, node_prefix: "item").build(
  hide_descendants_path_builder: ->(item, depth, scope) {
    view_context.remove_descendants_item_path(item, depth: depth + 1, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    view_context.show_descendants_item_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    state == :collapsed ? view_context.items_path(collapsed: "all") : view_context.items_path
  }
)
```

静的表示だけなら `build_static` を使えます。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static
```

### RenderState

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "items/tree_columns",
  ui_config: tree_ui,
  initial_state: :collapsed
)
```

### 完成例

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

```slim
table.tree-view-table
  thead
    tr
      th level
      th name
      th owner
  tbody
    = render partial: "tree_view/tree_row",
      collection: @render_state.root_items,
      as: :item,
      locals: {
        tree: @render_state.tree,
        row_partial: @render_state.row_partial
      }
```

row partial:

```slim
/ app/views/projects/_tree_columns.html.slim
td = item.name
td = item.owner_name
```

Turbo Stream で開閉したい場合は、`build` に path builder を渡し、同じ `tree_row` を render します。`@tree_ui` が static でなければ既定で turbo toggle partial を使います。

### Global config

```ruby
TreeView.configure do |config|
  config.initial_state = :expanded
end
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rake build
```

### Container

ローカル Ruby を入れずに試す場合は Docker を使えます。

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app bundle exec rspec
docker compose run --rm app bundle exec rake build
```

VS Code Dev Containers を使う場合は `.devcontainer/devcontainer.json` をそのまま使えます。

## License

MIT
