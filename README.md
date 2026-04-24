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

## License

MIT
