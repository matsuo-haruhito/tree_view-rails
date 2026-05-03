# Persisted State 設計方針

TreeView の開閉状態をユーザーごと・画面ごとに保存/復元するための設計方針です。

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

`collapsed_keys` は将来的な拡張候補です。

`initial_state: :collapsed` と `expanded_keys` の組み合わせで実用的に復元でき、状態設計も単純に保てます。

## view_key

保存状態は画面ごとに分ける必要があるため、`view_key` を使います。

```ruby
"documents#index"
"projects#show:123"
"admin/categories#index"
```

`view_key` の生成方法は host app 側で決めます。
TreeView gem は `view_key` を受け取り、JavaScript hook や persisted state object に渡せるようにするだけに留めます。

## owner

DB 永続化では、`User` 固定ではなく polymorphic owner を基本案とします。

```ruby
owner_type
owner_id
view_key
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
- `view_key` の決定
- 認証・権限チェック
- 保存 endpoint の routing
- 見えなくなった node_key の扱い
- 保存頻度、debounce、保存タイミングの判断

## API イメージ

```ruby
saved_state = TreeView::PersistedState.new(
  view_key: "documents#index",
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
owner.tree_view_state_for("documents#index")
owner.save_tree_view_state!("documents#index", expanded_keys: params[:expanded_keys])
```

## DB 永続化の雛形

Generator で作る migration は、owner を polymorphic にして host app 側の user model 名へ依存しない形にします。

```ruby
create_table :tree_view_states do |t|
  t.references :owner, polymorphic: true, null: false
  t.string :view_key, null: false
  t.json :expanded_keys, null: false, default: []
  t.timestamps
end

add_index :tree_view_states, [:owner_type, :owner_id, :view_key], unique: true
```

生成される model は host app 側に置き、gem 本体の利用には必須にしません。

```ruby
class TreeViewState < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :view_key, presence: true
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

## 実装順序

1. persisted state の基本設計を docs に固定する
2. 開閉状態を JavaScript から取得・通知できる hook を追加する
3. 保存済み `expanded_keys` の復元補助 API を追加する
4. DB 永続化用 generator を追加する
5. controller / helper API を追加する
