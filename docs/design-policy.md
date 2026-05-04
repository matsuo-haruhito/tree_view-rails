# 設計思想と責務範囲

## 目的

`tree_view` は、Rails 7 以降の host app から使える、親子データ表示用のツリー基盤を提供するgemです。

このリポジトリは `tree_view` gem 本体専用として扱います。旧 sample app 由来のCRUDやdemo画面は含めません。

## 基本方針

- `TreeView` コアは木構造ロジックと描画統合の薄い入口に寄せる
- host app 固有の route 名、文言、CRUD、業務処理は持ち込まない
- `UiConfig` / `UiConfigBuilder` は generic な builder に留める
- row partial 差し替えを公開拡張ポイントとして維持する
- static表示だけでも使えるようにし、Turbo開閉を必須にしない
- root / children の並び順は `TreeView::Tree` の sorter で一元化する
- 既定の並び順は後方互換のため子孫数昇順とする

## rendering API に関する方針

当面の公開描画入口は `TreeView::RenderState`、`tree_view_rows(render_state)`、host app が渡す `row_partial` を中心にします。

ViewComponent-style API は、現時点では TreeView gem 側では提供しません。ViewComponent gemへの依存を追加せず、必要なhost appでは薄いcomponentから `tree_view_rows(render_state)` を呼び出す構成を推奨します。

column definition API も、現時点では提供しません。TreeViewが汎用table DSLへ寄りすぎることを避け、列のHTML、link、badge、button、権限制御、表示形式はhost appのpartial/helperに残します。

この方針により、TreeViewは木構造表示の基盤に留まり、画面フレームワーク化を避けます。

## deep tree に関する方針

現時点の `TreeView` は、通常の業務アプリで扱う親子階層を主対象とします。

`descendant_counts`、leaf distance、branch map、partial render には再帰的な処理が含まれるため、極端に深いツリーでは Ruby の stack limit や描画コストの影響を受ける可能性があります。

そのため、深い階層を扱う host app では以下を優先します。

- `max_render_depth` で一度に描画する深さを制限する
- `max_initial_depth` で初期表示時の展開範囲を制限する
- 必要に応じて `max_leaf_distance` で末端付近だけを表示する
- `path_tree_for` / `reverse_tree_for` で検索結果や注目ノード周辺に表示範囲を絞る
- 非常に深いデータをそのまま全展開する UI は避ける

将来的に極端な deep tree を正式にサポートする場合は、再帰 walk の一部を iterative な実装へ置き換える、または最大深度ガードを追加することを検討します。

## 含めるもの

- `lib/tree_view*`
- `tree_view.gemspec`
- `app/helpers/tree_view_helper.rb`
- `app/views/tree_view/*`
- `app/assets/stylesheets/tree_view.scss`
- `app/javascript/tree_view/*`
- `config/importmap.tree_view.rb`
- gem 本体に対応するREADME、docs、spec

## 含めないもの

- sample app の controller / model / view / form
- host app 固有のCRUD
- host app 固有のTurbo Stream更新処理
- Turbo Frame modal
- 右クリックメニュー
- seed / demo data / screenshots
- DB / 認証 / 権限管理まわり

## 固定してよい判断

- `initial_state` の優先順位は `RenderState > global config > :expanded`
- `tree_toggle_all_path(state:)` を正規APIとし、`tree_expand_all_path` / `tree_collapse_all_path` は補助APIとする
- 全体開閉の対象範囲は当面 `all` のみ
- 枝表現は helper 側で tree 全体から計算する
- `row_partial` は host app 側で渡す
- gem側で sample app 名の partial を既定値にしない
- `UiConfig` の開閉 path builder は optional
- static tree では開閉path未指定を許容する
- toggle UI は `mode: :turbo | :static` で切り替える

## 今後の拡張方針

今後の機能追加は、host app 固有の画面機能ではなく、複数のRailsアプリで再利用できるツリー表示基盤として価値があるものに限定します。

候補例:

- orphan node handling
- 子ノード起点の親階層補完Tree
- 親方向へ辿る逆向きTreeView
- ノード単位の初期展開状態
- row class / data属性 builder
- node_key / DOM ID 衝突検出
- deep tree 向けの iterative walk または最大深度ガード

これらも、CRUDや業務処理をgemに取り込むのではなく、host app が表示を組み立てるための拡張ポイントとして実装します。
