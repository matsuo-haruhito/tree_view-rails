# Architecture

## Purpose

このリポジトリは、親子データをツリー表示する `TreeView` を Rails アプリ内で育てつつ、将来的な GEM 化を見据えて責務分離を進めるためのものです。

## Responsibility Split

### TreeView core

- `TreeView::Tree`
  - 親子解決
  - 子孫数集計
  - ルート並び替え
- `TreeView::Traversal`
  - 子孫 ID の収集
- `TreeView::GraphAdapter`
  - 異種ノード混在ツリーの接続
- `TreeView::RenderState`
  - 画面ごとの描画状態
- `TreeView::UiConfig`
  - DOM ID と path helper 周辺
- `TreeView::Configuration`
  - 全体既定値

### Sample app side

- `items`
  - 自己参照ツリーのサンプル
- `machines`
  - `Machine / Unit / Part / Material` 混在ツリーのサンプル
- row partial
  - 行描画差し替え
- Turbo Stream / Turbo Frame
  - sample app の UI 統合例
- CRUD
  - sample app の機能
- 右クリックメニュー
  - sample app の機能

## How It Is Intended To Be Used

GEM として想定している使い方は、次の 3 段です。

1. アプリ全体の既定値を initializer で設定する
2. controller で `Tree`, `UiConfig`, `RenderState` を組み立てる
3. view では `RenderState` が持つ情報と helper を使って描画する

### 1. Global config

想定する記載場所:

- `config/initializers/tree_view.rb`

例:

```ruby
TreeView.configure do |config|
  config.initial_state = :expanded
end
```

ここで設定するのは「画面ごとに未指定だった場合の既定値」です。  
今のところ global config に置くのは `initial_state` のみです。

### 2. Controller side

controller では、次の 3 つを用意して `RenderState` にまとめる想定です。

- `TreeView::Tree`
- `TreeView::UiConfig`
- `TreeView::RenderState`

自己参照モデルの最小イメージ:

```ruby
def index
  tree = TreeView::Tree.new(
    records: Item.select(:id, :parent_item_id, :name).to_a,
    parent_id_method: :parent_item_id
  )

  ui_config = TreeView::UiConfigBuilder.new(context: self).build(
    hide_descendants_path_builder: ->(item, display_depth, scope) {
      remove_descendants_item_path(item, depth: display_depth + 1, scope: scope, format: :turbo_stream)
    },
    show_descendants_path_builder: ->(item, toggle_depth, scope) {
      show_descendants_item_path(item, depth: toggle_depth, scope: scope, format: :turbo_stream)
    },
    toggle_all_path_builder: ->(state) {
      state == :collapsed ? items_path(collapsed: "all") : items_path
    }
  )

  @render_state = TreeView::RenderState.new(
    tree: tree,
    root_items: tree.root_items,
    row_partial: "items/tree_columns",
    ui_config: ui_config,
    initial_state: :collapsed
  )
end
```

ポイント:

- `Tree` は木構造そのもの
- `UiConfig` は DOM ID と path helper の差分
- `RenderState` は「この画面ではどう描くか」

異種ノード混在ツリーのイメージ:

このパターンは自己参照モデルより一段特殊です。理由は、親子関係が 1 つのテーブルに閉じず、ノード種別ごとに「次にぶら下がれる相手」が違うからです。

一般化すると、たとえば次のようなツリーを扱うイメージです。

```text
RootNode
└── GroupNode
    └── LeafNode
```

※ ただし、`RootNode` の下に `RootNode` がぶら下がるような構成も可能です。  
※ どの型のノードが、どの型の子を持てるかはアプリ側で定義します。

`machines` サンプルでは、これを次のような具体形で扱っています。

```text
Machine
├── Machine
├── Unit
│   ├── Unit
│   └── Part
└── Part
    └── Material
```

ここで難しいのは、`TreeView::Tree` に直接この構造を覚えさせると、Tree 自体が `Machine` や `Unit` を知る必要が出てしまうことです。  
そのため、このパターンでは `GraphAdapter` に次の責務を持たせます。

- root は何か
- 各ノードの子は何か
- ノードを一意に識別するキーは何か

言い換えると、`GraphAdapter` は「アプリ固有の親子ルール」を TreeView コアへ橋渡しする層です。

コードの書き方としては、まず「root を何にするか」と「各ノードがどの子を返すか」を決めて、それを `GraphAdapter` に渡します。

簡単版の実装イメージ:

```ruby
roots = RootNode.where(parent_id: nil).to_a

group_nodes_by_root_id = GroupNode.all.group_by(&:root_node_id)
leaf_nodes_by_group_id = LeafNode.all.group_by(&:group_node_id)

adapter = TreeView::GraphAdapter.new(
  roots: roots,
  children_resolver: lambda do |node|
    case node
    when RootNode
      Array(group_nodes_by_root_id[node.id])
    when GroupNode
      Array(leaf_nodes_by_group_id[node.id])
    else
      []
    end
  end,
  node_key_resolver: ->(node) { [node.class.name, node.id] }
)

tree = TreeView::Tree.new(adapter: adapter)
```

この簡単版では、

- `RootNode` の子は `GroupNode`
- `GroupNode` の子は `LeafNode`
- `LeafNode` は子を持たない

というだけです。  
まずはこの形で `GraphAdapter` の役割を理解すると、`machines` のような「1つの型が複数種類の子を持つ」パターンも追いやすくなります。

実装イメージ:

```ruby
def index
  machines = Machine.order(:id).to_a
  units = Unit.order(:id).to_a
  parts = Part.order(:id).to_a
  materials = Material.order(:id).to_a

  child_machines_by_parent_id = machines.group_by(&:parent_machine_id)
  root_units_by_machine_id = units.select { |unit| unit.parent_unit_id.nil? }.group_by(&:machine_id)
  child_units_by_parent_id = units.group_by(&:parent_unit_id)
  machine_level_parts_by_machine_id = parts.select { |part| part.unit_id.nil? }.group_by(&:machine_id)
  unit_parts_by_unit_id = parts.group_by(&:unit_id)
  materials_by_part_id = materials.group_by(&:part_id)

  roots = machines.select { |machine| machine.parent_machine_id.nil? }

  adapter = TreeView::GraphAdapter.new(
    roots: roots,
    children_resolver: lambda do |node|
      case node
      when Machine
        Array(child_machines_by_parent_id[node.id]) +
          Array(root_units_by_machine_id[node.id]) +
          Array(machine_level_parts_by_machine_id[node.id])
      when Unit
        Array(child_units_by_parent_id[node.id]) +
          Array(unit_parts_by_unit_id[node.id])
      when Part
        Array(materials_by_part_id[node.id])
      else
        []
      end
    end,
    node_key_resolver: ->(node) { [node.class.name, node.id] }
  )

  tree = TreeView::Tree.new(adapter: adapter)

  ui_config = TreeView::UiConfigBuilder.new(
    context: self,
    node_prefix: "node",
    key_resolver: ->(node_or_id) {
      if node_or_id.respond_to?(:id)
        "#{node_or_id.class.name.underscore}_#{node_or_id.id}"
      else
        node_or_id
      end
    }
  ).build(
    hide_descendants_path_builder: ->(node, display_depth, scope) {
      remove_descendants_machines_path(
        node_type: node.class.name,
        node_id: node.id,
        depth: display_depth + 1,
        scope: scope,
        format: :turbo_stream
      )
    },
    show_descendants_path_builder: ->(node, toggle_depth, scope) {
      show_descendants_machines_path(
        node_type: node.class.name,
        node_id: node.id,
        depth: toggle_depth,
        scope: scope,
        format: :turbo_stream
      )
    },
    toggle_all_path_builder: ->(state) {
      state == :collapsed ? machines_path(collapsed: "all") : machines_path
    }
  )

  @render_state = TreeView::RenderState.new(
    tree: tree,
    root_items: tree.root_items,
    row_partial: "machines/tree_columns",
    ui_config: ui_config
  )
end
```

このパターンでは、

- `TreeView::Tree` 自体は異種ノードを知らない
- `GraphAdapter` が「何が root で、各ノードの子は何か」を解決する
- `UiConfig` 側で `node_type` / `node_id` を path に載せる

という分担になります。

もう少し具体的に言うと、

- `Machine`
  - 子として `Machine`, `Unit`, `Part` を返しうる
- `Unit`
  - 子として `Unit`, `Part` を返しうる
- `Part`
  - 子として `Material` を返しうる
- `Material`
  - 子は持たない

という「アプリごとのルール」を `children_resolver` に閉じ込めています。

そのうえで、path 生成時には `id` だけでは種別が判別できないので、`node_type` と `node_id` の両方を URL に載せています。  
このため、異種ノード混在パターンでは `UiConfigBuilder` に渡す `key_resolver` も自己参照版より重要になります。

もし導入先アプリで似た要件があるなら、最初から `Tree` を直接いじるのではなく、

1. まず「root は何か」を決める
2. 次に「各ノードの子を返す resolver」を決める
3. 最後に `GraphAdapter` を `TreeView::Tree.new(adapter: ...)` へ渡す

の順で考えると整理しやすいです。

`initial_state` の優先順位は次のとおりです。

1. `RenderState#initial_state`
2. `TreeView.configure`
3. `:expanded`

### 3. View side

view では、path の組み立てを知らずに helper を呼べる形を目指しています。

例:

```slim
= link_to "すべて広げる", tree_expand_all_path
= link_to "すべて畳む", tree_collapse_all_path
```

正規 API は次です。

```ruby
tree_toggle_all_path(state: :expanded)
tree_toggle_all_path(state: :collapsed)
```

`tree_expand_all_path` / `tree_collapse_all_path` は sugar alias です。

## Which Files Matter

GEM 利用者が主に触ることになるファイルや層は次です。

### host app 側で触る場所

- `config/initializers/tree_view.rb`
  - global config
- controller
  - `Tree`, `UiConfig`, `RenderState` の組み立て
- row partial
  - 行ごとの表示差し替え
- view
  - `tree_toggle_all_path` などの helper 呼び出し

### GEM 側で安定させたい場所

- `TreeView::Tree`
- `TreeView::Traversal`
- `TreeView::GraphAdapter`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView.configure`

## Example Mapping In This Repository

このリポジトリ内では、実際に次のファイルがその役割を持っています。

- global config の入口
  - `lib/tree_view.rb`
  - `lib/tree_view/configuration.rb`
- 描画状態
  - `lib/tree_view/render_state.rb`
- path/DOM ID 設定
  - `lib/tree_view/ui_config.rb`
  - `lib/tree_view/ui_config_builder.rb`
- 自己参照サンプルの組み立て
  - `app/controllers/items_controller.rb`
- 異種ノード混在サンプルの組み立て
  - `app/controllers/machines_controller.rb`
- helper の公開面
  - `app/helpers/items_helper.rb`

## Current Boundaries

GEM 候補:

- `lib/tree_view/*`
- `app/assets/stylesheets/tree_view.scss`
- `app/javascript/tree_view/*`

sample app 専用:

- Turbo refresh
- CRUD
- Turbo Frame modal
- `sample_crud.scss`
- `modal_frame_controller.js`
- 右クリックメニューの文言や配置など、アプリ都合の UI

## Pagination Policy

- `Kaminari` は root collection にだけ適用する
- 各 root の配下は同じページ内で完結させる
- 全ノード paginate はしない
