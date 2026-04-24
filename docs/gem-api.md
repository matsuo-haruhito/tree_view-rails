# GEM API Draft

## What This GEM Provides

この GEM が提供したいものは、主に次の 3 層です。

- 木構造ロジック
  - 親子解決
  - 子孫数集計
  - 走査
- 描画状態
  - どの root 群を描くか
  - どの partial で描くか
  - 初期表示モードをどうするか
- Rails 統合の薄い入口
  - DOM ID
  - path helper
  - 全体開閉 helper

逆に、現時点で GEM 本体に入れない前提のものは次です。

- Turbo broadcast
- CRUD
- Turbo Frame modal
- 右クリックメニューの文言や配置
- sample app 固有の UI 調整

つまり、この GEM は「完成済みの管理画面部品」ではなく、
「親子データをツリー表示するための土台」を提供する方向です。

## Global Config

TreeView 全体の既定値は `TreeView.configure` で設定する想定です。

```ruby
TreeView.configure do |config|
  config.initial_state = :expanded
end
```

現時点で global config に置くのは `initial_state` のみです。

## RenderState

画面ごとの上書きは `TreeView::RenderState` で行います。

```ruby
TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "items/tree_columns",
  ui_config: ui_config,
  initial_state: :collapsed
)
```

`initial_state` の優先順位は次のとおりです。

1. `RenderState#initial_state`
2. `TreeView.configure`
3. `:expanded`

扱う値は当面 `:expanded` / `:collapsed` のみです。

## Toggle-All API

全体開閉の本体は `UiConfig#toggle_all_path(state:)` です。  
view からは helper 経由で呼ぶ想定です。

```ruby
tree_toggle_all_path(state: :collapsed)
tree_expand_all_path
tree_collapse_all_path
```

方針:

- 正規 API は `tree_toggle_all_path(state: :expanded | :collapsed)`
- `tree_expand_all_path` / `tree_collapse_all_path` は sugar alias
- 対象範囲は当面 `all` のみ

## UiConfig

`UiConfig` は DOM ID と path helper 周辺に留めます。  
見た目設定や CSS 上書き方針は `UiConfig` に入れません。

## Asset Integration

現時点では、TreeView 固有の CSS と JS も GEM 候補として扱っています。

### CSS

TreeView の基本スタイルは `tree_view.scss` にあります。  
host app 側では application stylesheet から読み込む想定です。

```scss
@import "./tree_view";
```

この CSS は最低限の見た目を提供するもので、導入先アプリ側で上書きする前提です。

### JavaScript

現時点の JS は Stimulus + importmap 前提です。

GEM 側は `tree_view` と `tree_view/controllers/*` を配り、host app 側で Stimulus application に登録する形を想定しています。

```javascript
import { application } from "controllers/application"
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

この構成にしている理由は、

- GEM 側が host app の `controllers/application` に直接依存しない
- host app 側が既存の Stimulus application に明示的に組み込める

ためです。

### Importmap

importmap を使う場合は、最終的に次の pin が見える状態を想定しています。

```ruby
pin "tree_view", to: "tree_view/index.js"
pin_all_from "app/javascript/tree_view/controllers", under: "tree_view/controllers"
```

このリポジトリでは、TreeView 用の pin を `config/importmap.tree_view.rb` に分けています。

## Future Extensions

将来候補としては次を想定しています。

- `:roots_only`
- `:depth_limited`
- custom initial state
- `initial_state_resolver`
- options object 分離
- session / params 連動
