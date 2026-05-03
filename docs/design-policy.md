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

これらも、CRUDや業務処理をgemに取り込むのではなく、host app が表示を組み立てるための拡張ポイントとして実装します。
