# Persisted State 設計方針

TreeView の開閉状態をユーザーごと・TreeViewインスタンスごとに保存/復元するための設計方針です。

## 目的

ドキュメントツリー、カテゴリツリー、組織ツリーでは、利用者が毎回同じ階層を開いて作業することがあります。
最後に開いていた状態を次回表示時に復元できると、host app の使い勝手が向上します。

一方で、保存先、認証、owner の扱いは host app ごとに異なるため、TreeView gem 本体へ DB や認証の前提を強く持ち込まない方針とします。

## 基本方針

- gem 本体は、開閉状態の復元・通知の基盤を提供する
- DB 永続化は optional generator として提供する
- DB 永続化を使わない host app には migration / model を要求しない
- 特定の認証 gem や特定の user model 名には依存しない
- 保存先は host app 側で選べる余地を残す

## 保存対象

初期実装では `expanded_keys` を主対象とします。

```ruby
expanded_keys: ["document:1", "document:2"]
```

`collapsed_keys` は `RenderState` の初期表示制御APIとして利用できます。
永続化対象としては、状態保存を単純に保つため `expanded_keys` を基本にします。
`initial_state: :collapsed` と `expanded_keys` の組み合わせで、最後に開いていた状態を実用的に復元できます。

## tree_instance_key

保存状態は TreeView インスタンスごとに分ける必要があるため、`tree_instance_key` を使います。

```ruby
"documents#index:main_tree"
"projects#show:123:documents_tree"
"admin/categories#index:category_tree"
```

`tree_instance_key` は host app の業務IDではありません。
TreeView gem が「この開閉状態はどの TreeView インスタンスのものか」を判断するための識別子です。

同じ画面に複数の TreeView が存在し、それぞれに同じ `node_key` が含まれる場合、`node_key` だけでは状態を安全に分離できません。
そのため、host app は TreeView インスタンスごとに一意な `tree_instance_key` を指定します。

```ruby
folder_render_state = TreeView::RenderState.new(
  tree: folder_tree,
  root_items: folder_tree.root_items,
  row_partial: "folders/tree_columns",
  ui_config: folder_tree_ui,
  tree_instance_key: "folder_tree"
)

category_render_state = TreeView::RenderState.new(
  tree: category_tree,
  root_items: category_tree.root_items,
  row_partial: "categories/tree_columns",
  ui_config: category_tree_ui,
  tree_instance_key: "category_tree"
)
```

TreeView gem 側では、実質的に `folder_tree / 1` と `category_tree / 1` のように区別できます。

## owner

DB 永続化では、`User` 固定ではなく polymorphic owner を基本案とします。

```ruby
owner_type
owner_id
tree_instance_key
```

これにより、`User`、`AccountUser`、`Member`、tenant 内ユーザーなどの違いに対応しやすくします。

## 責務範囲

### gem 本体

- `expanded_keys` を受け取って初期展開状態に反映する
- 開閉状態を JavaScript から収集できる hook を提供する
- 開閉状態変更時に event を dispatch できるようにする
- persisted state を `RenderState` に接続しやすい value object / option を提供する

### optional persistence

- migration generator
- model / concern generator
- load / save API
- controller / helper から使いやすい補助 API

### host app

- owner の決定
- `tree_instance_key` の決定
- 認証・権限チェック
- 保存 endpoint の routing
- 見えなくなった node_key の扱い
- 保存頻度、debounce、保存タイミングの判断

## API イメージ

```ruby
saved_state = TreeView::PersistedState.new(
  tree_instance_key: "documents#index:main_tree",
  expanded_keys: saved_expanded_keys
)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  persisted_state: saved_state
)
```

DB 永続化を使う場合は、generator で host app 側に保存用モデルを追加します。

```bash
rails g tree_view:state:install
rails db:migrate
```

owner 側 API の例です。

```ruby
owner.tree_view_state_for("documents#index:main_tree")
owner.save_tree_view_state!("documents#index:main_tree", expanded_keys: params[:expanded_keys])
```

## DB 永続化の雛形

Generator で作る migration は、owner を polymorphic にして host app 側の user model 名へ依存しない形にします。

```ruby
create_table :tree_view_states do |t|
  t.references :owner, polymorphic: true, null: false
  t.string :tree_instance_key, null: false
  t.json :expanded_keys, null: false, default: []
  t.timestamps
end

add_index :tree_view_states, [:owner_type, :owner_id, :tree_instance_key], unique: true
```

生成される model は host app 側に置き、gem 本体の利用には必須にしません。

```ruby
class TreeViewState < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :tree_instance_key, presence: true
end
```

owner 側には concern を include して、読み書きの入口を揃えます。

```ruby
class User < ApplicationRecord
  include TreeViewStateOwner
end
```

## 保存先ごとの考え方

| 保存先 | 特徴 | gem 側の関与 |
|---|---|---|
| DB | 別端末でも復元できる | optional generator で支援する |
| cookie / session | 小規模な状態保存に向く | host app 側で実装する |
| localStorage | サーバ実装なしで使えるが端末依存 | JavaScript hook で支援する余地を残す |

## 注意点

保存する値は `tree.node_key_for(item)` の戻り値です。
node_key の生成ルールを変更すると、保存済み状態が復元できなくなる可能性があります。

保存済みの `expanded_keys` に、現在の利用者が参照できないノードが含まれる場合があります。
その除去・無視・再保存は host app 側の責務とします。
