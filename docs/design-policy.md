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
- `VisibleRows` で表示行を一次元化し、host app 側の windowing や検査ロジックに渡す
- 非常に深いデータをそのまま全展開する UI は避ける

極端な deep tree 専用の DOM 仮想化やスクロール制御は host app 側の責務とします。TreeView gem 側は表示範囲制御と visible-row モデルの提供に留めます。

## Turbo / remote update の責務境界

TreeView は Turbo Stream や remote children を使う画面でも、通信処理そのものは持たず、host app が安全に更新処理を組み立てるための情報と hook を提供します。

TreeView gem が担当する範囲は以下です。

- DOM ID / checkbox ID / toggle button ID の安定生成
- `UiConfig` / path builder による hide / show / toggle-all URL 生成の入口
- `data-*` 属性による node_key・depth・選択状態・行状態などの表示補助情報の付与
- 必要に応じた共通 CSS class / JavaScript event 名・payload の標準化
- loading / error / retry など remote operation の状態表現に必要な hook の提供

host app が担当する範囲は以下です。

- controller action / route / authorization
- DB query / pagination / lazy load 対象の決定
- Turbo Stream response の内容
- WebSocket / Turbo Streams broadcast の購読・配信
- retry 処理やエラーメッセージの業務判断
- 削除・移動・関連付けなどの業務処理

Turbo Stream response は、TreeView が生成した DOM ID を target として使い、置換・追加するHTMLは既存の `tree_view_rows` / partial 構造と互換にします。
node_key / DOM ID が重複しないよう、必要に応じて `node_prefix` や `TreeView.node_key` を使います。
WebSocket / Turbo Streams broadcast で別クライアントへ反映する場合も、TreeView は購読や配信を管理しません。

この方針により、TreeView は Rails / Turbo と相性のよい表示基盤に留まり、通信制御ライブラリや業務UIフレームワークには寄せません。

## JavaScript controller responsibilities

TreeView の JavaScript は、host app の業務処理を実行するものではなく、TreeView のDOMから標準化されたイベントと状態hookを提供する薄い層として扱います。

TreeView gem 側が担当してよいもの:

- TreeView DOM内のクリック、選択、開閉補助、drag/drop補助イベントを標準イベントへ変換する
- event detail に node key、tree identifier、selection payload などの汎用情報を含める
- loading / error / retry など、remote operation の表示状態に必要な class / `aria-*` / data属性を付け外しする
- checkbox selection の現在状態を読み取り、host app が送信・API呼び出しに使える payload を組み立てる
- keyboard navigation など、TreeView DOM内で完結するアクセシビリティ補助を提供する

host app 側に残すもの:

- fetch / Turbo request の実行判断
- controller action やAPI endpointの選択
- authorization / validation
- DB更新、関連付け、移動、削除などの業務処理
- エラーメッセージの業務文言
- 画面遷移や詳細ペイン更新などのアプリ固有UI制御

今後 controller を分割する場合は、機能ごとに小さく保ちます。

- selection: checkbox selection と selection-change event
- row-events: row click / double-click event
- transfer: drag and drop / move intent event
- remote-state: loading / error / retry state hook
- keyboard: focus movement and keyboard navigation

controller 間で共有する event detail は `docs/public-api.md` に記載してから host app 向けの公開hookとして扱います。

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

## 拡張判断の基準

追加機能は、host app 固有の業務処理ではなく、複数のRailsアプリで再利用できるツリー表示基盤として価値があるものに限定します。

TreeView gem 側では、表示範囲制御、render state、stable DOM hook、visible-row モデルのような土台を持ちます。CRUD、認証、ページング戦略、DOM 仮想スクロール本体、業務固有メッセージは host app 側に残します。
