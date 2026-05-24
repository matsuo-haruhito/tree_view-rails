# Persisted State

このページでは、TreeViewの開閉状態をhost app側に保存・復元するためのAPIを説明します。

## 概要

persisted state は、ユーザーや画面単位でTreeViewの展開状態を保存し、次回表示時に復元するための機能です。

TreeView gem が担当するのは以下です。

- persisted stateを表す `TreeView::PersistedState`
- host app model経由で保存/読み込みする `TreeView::StateStore`
- migration / model / concern を生成する install generator
- `RenderState` へ persisted expanded keys を渡すための構造

実際の保存先、owner model、認可、保存タイミング、controller action、UI更新はhost app側で実装します。

## generator

保存用modelとmigrationの雛形は generator で作成できます。

```bash
bin/rails generate tree_view:state:install
```

生成される主なファイル:

- `db/migrate/*_create_tree_view_states.rb`
- `app/models/tree_view_state.rb`
- `app/models/concerns/tree_view_state_owner.rb`

migrationを確認してから実行してください。

```bash
bin/rails db:migrate
```

### owner concern を自動で include する

既存の owner model に `TreeViewStateOwner` を include したい場合は、owner model 名を渡します。

```bash
bin/rails generate tree_view:state:install User
```

この場合も、migration、model、concern は通常どおり生成されます。`app/models/user.rb` が存在し、まだ `TreeViewStateOwner` を include していなければ、generator が include 行を追加します。

owner model file が存在しない場合、model への注入は skip されます。その場合は concern を手動で include してください。

## owner model

host app側のowner modelに concern をincludeします。

```ruby
class User < ApplicationRecord
  include TreeViewStateOwner
end
```

ownerは、ユーザー、workspace、project、または画面状態を所有する任意のmodelにできます。

## StateStore

`TreeView::StateStore` は、owner と tree instance key を使って persisted state を読み書きします。

```ruby
store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "documents:index"
)

persisted_state = store.load
```

開閉状態を保存する例:

```ruby
persisted_state = store.save(expanded_keys: expanded_keys)
```

## RenderStateとの連携

読み込んだpersisted stateは `RenderState` に渡せます。

```ruby
persisted_state = store.load

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  persisted_state: persisted_state
)
```

明示的に `expanded_keys` を指定した場合は、明示指定が persisted state より優先されます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  persisted_state: persisted_state,
  expanded_keys: forced_expanded_keys
)
```

## tree instance key

`tree_instance_key` は、保存状態を分けるためのkeyです。

例:

- `documents:index`
- `projects:sidebar`
- `workspace:#{workspace.id}:documents`

同じownerでも画面やtreeが異なる場合は、別のkeyを使ってください。

## 1 つの host app で複数 tree instance を使う

同じ owner に対して、sidebar tree と詳細 tree のように複数の persisted tree を並行運用できます。

```ruby
sidebar_store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "projects:sidebar"
)

detail_store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "projects:#{project.id}:detail"
)

sidebar_state = sidebar_store.load

detail_state = detail_store.load
```

読み込んだ state は、それぞれ対応する render state に渡します。

```ruby
@sidebar_render_state = TreeView::RenderState.new(
  tree: sidebar_tree,
  root_items: sidebar_tree.root_items,
  row_partial: "projects/sidebar_tree_columns",
  ui_config: sidebar_tree_ui,
  persisted_state: sidebar_state
)

@detail_render_state = TreeView::RenderState.new(
  tree: detail_tree,
  root_items: detail_tree.root_items,
  row_partial: "projects/detail_tree_columns",
  ui_config: detail_tree_ui,
  persisted_state: detail_state
)
```

key を決めるときは、次の考え方を使うと整理しやすくなります。

- `sidebar`、`index`、`detail` のように、配置場所や責務ごとに key を分ける
- 詳細 tree がページごとに変わる場合は、record ID や workspace ID を key に含める
- 2 つの描画で本当に同じ展開状態を共有したい場合だけ、同じ key を再利用する

TreeView が保存するのは expanded keys です。保存 request の入口、更新をいつ永続化するか、現在の render scope とどう組み合わせるかは引き続き host app 側で決めます。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| persisted state value object | yes | no |
| generated model/migration template | yes | reviews and migrates |
| loading/saving through StateStore | yes | provides owner and key |
| choosing owner model | optional generator argument | yes |
| deciding save timing | no | yes |
| controller/API endpoint | no | yes |
| authorization | no | yes |
| UI event wiring | hooks only | yes |