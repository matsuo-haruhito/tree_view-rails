# TreeView Context

## 目的
- このリポジトリは `tree_view` GEM 本体専用のリポジトリとして扱う。
- Rails 7 以降の host app から使える、親子データ表示用のツリー基盤を提供する。
- sample app 固有の UI や CRUD ではなく、再利用可能な tree rendering core に責務を絞る。

## 基本方針
- `TreeView` コアは木構造ロジックと描画統合の薄い入口に寄せる。
- host app 固有の route 名、文言、Turbo Stream 更新、CRUD はこの repo に含めない。
- `UiConfig` / `UiConfigBuilder` は generic な builder に留め、特定画面向け sugar は持ち込まない。
- row partial 差し替えを公開拡張ポイントとして維持する。
- host app が静的表示だけで使えるように、Turbo 開閉前提を必須にしない。

## GEM 本体に含めるもの
- `lib/tree_view*`
- `tree_view.gemspec`
- `app/helpers/tree_view_helper.rb`
- `app/views/tree_view/*`
- `app/assets/stylesheets/tree_view.scss`
- `app/javascript/tree_view/*`
- `config/importmap.tree_view.rb`
- GEM 本体に対応する README / spec / 最小ドキュメント

## GEM 本体に含めないもの
- sample app の controller / model / view / form
- Turbo refresh 購読
- CRUD
- Turbo Frame modal
- 右クリックメニュー
- seed / demo data / screenshots
- Docker / DB / 認証まわり

## 現在の公開 API
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
- `TreeView::UiConfig`
  - DOM ID と path helper 生成
- `TreeView::UiConfigBuilder`
  - generic builder
- `TreeViewHelper`
  - DOM ID / toggle path / 枝情報 helper

## 固定してよい判断
- `initial_state` の優先順位は `RenderState > global config > :expanded` とする。
- `tree_toggle_all_path(state:)` を正規 API とし、`tree_expand_all_path` / `tree_collapse_all_path` を sugar alias とする。
- 全体開閉の対象範囲は当面 `all` のみとする。
- 枝表現は helper 側で tree 全体から計算する。
- `row_partial` は host app 側で渡す前提にし、gem 側で sample app 名を既定値にしない。
- `UiConfig` の開閉 path builder は optional とし、static tree では未指定を許容する。
- toggle UI は `mode: :turbo | :static` で切り替え、既定値は後方互換のため `:turbo` とする。
- README には Rails 8 + Propshaft を含む host app 導入例と、`render "tree_view/tree_row"` の完成例を載せる。

## 現在の作業
- [ ] 外部 host app から install して動作確認する
- [x] importmap / asset 読み込み手順を README 上で過不足なく整理する
- [x] static tree 用の API / partial を追加する
- [x] gem に無関係な sample app view 残骸を取り除く
- [ ] 必要なら dummy app か integration spec を追加する
