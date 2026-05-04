# 用語集

TreeView 固有の概念を、ドキュメント上の呼び方・コード上の表現・説明で整理します。

Rails 一般の用語ではなく、この gem の API や設計判断に関わる用語を中心にまとめています。実装時に名前や責務で迷った場合は、まずこの用語集を確認してください。

| ドキュメント上の表示 | コード上の表示 | 説明 |
|---|---|---|
| TreeView | `tree_view` / `TreeView` | Rails app にツリー表示の描画基盤を提供する gem 全体を指します。CRUD、認可、業務処理は host app 側の責務です。 |
| Host app | Rails host application | この gem を組み込む利用側Railsアプリケーションです。業務モデル、controller、row partial、認可、保存処理を持ちます。 |
| Tree | `TreeView::Tree` | 親子関係を持つレコードやノードを TreeView が辿れる形にする中心オブジェクトです。 |
| Node | item / record / node | TreeView が1行として扱う対象です。Active Record model に限らず、resolver mode や GraphAdapter では任意のオブジェクトを扱えます。 |
| Node key | `node_key` / `tree.node_key_for(item)` | TreeView 内で node を識別するキーです。開閉状態、selection、row state、DOM連携の基礎になります。host app のDB主キーそのものとは限りません。 |
| TreeView instance key | `tree_instance_key` | 同一画面上の TreeView インスタンスを識別するためのキーです。host app の業務IDではなく、TreeView gem が「この行・状態はどのTreeViewに属するか」を区別するために使います。 |
| TreeView instance | `RenderState` + `tree_instance_key` | 画面上に配置された1つの TreeView 表示単位です。同じ画面に複数TreeViewがある場合、それぞれ別の `tree_instance_key` を持たせます。 |
| Root item | `root_items` / `tree.root_items` | 描画の起点となるnode配列です。通常は親を持たないnodeですが、PathTree や ReverseTree では用途に応じた起点になります。 |
| Children | `tree.children_for(item)` | 指定nodeの表示上の子nodeです。ReverseTree では親方向nodeが表示上のchildrenになります。 |
| Ancestors | `tree.ancestors_for(item)` | records mode で、root側から指定nodeの親までを並べた配列です。検索結果の親階層補完などに使います。 |
| Path | `tree.path_for(item)` / `tree.paths_for(items)` | root から指定nodeまでの並びです。検索結果を通常の階層内で見せるための材料になります。 |
| Path tree | `TreeView::PathTree` / `tree.path_tree_for(items)` | 指定nodeへ至る親階層を補完した通常向きTreeです。検索結果を root → ancestor → matched item の向きで表示します。 |
| Reverse tree | `TreeView::ReverseTree` / `tree.reverse_tree_for(items)` | 指定nodeを起点に親方向へ辿るTreeです。matched item → parent → root の向きで表示します。 |
| Graph adapter | `TreeView::GraphAdapter` | 異種node混在ツリーや、Active Record の単純な親子カラムでは表しにくい構造を TreeView に接続するadapterです。 |
| Orphan node | `orphan_items` / `orphan_strategy` | records mode で、親IDはあるが records 内に親nodeが存在しないnodeです。無視する、root扱いにする、例外にするなどを選べます。 |
| Orphan strategy | `orphan_strategy:` | orphan node の扱いを決める設定です。`:ignore`、`:as_root`、`:raise`、`:orphans_only` を使います。 |
| Render state | `TreeView::RenderState` | 画面単位の描画設定をまとめる公開APIオブジェクトです。tree、root_items、row_partial、ui_config、selection、scope などを保持します。 |
| Render context | `TreeView::RenderContext` | partial rendering 中に参照する内部寄りの描画文脈です。RenderState を元に、ERB partial が必要とする情報を提供します。 |
| Row context | `TreeView::RowContext` | 1行分の描画に必要な派生情報をまとめる文脈です。children、current状態、descendant count などを扱います。 |
| UI config | `TreeView::UiConfig` | DOM ID や開閉pathの作り方をまとめるオブジェクトです。通常は `TreeView::UiConfigBuilder` から作ります。 |
| UI config builder | `TreeView::UiConfigBuilder` | host app の view_context や path builder を元に `UiConfig` を作るためのbuilderです。 |
| Row partial | `row_partial:` | host app 側が用意する、業務列を描画するpartialです。TreeView は toggle cell や selection cell を提供し、業務列は host app に委ねます。 |
| Row actions partial | `row_actions_partial:` | 行ごとの操作列を host app 側で差し込むためのpartialです。TreeView は描画位置を提供し、実際の操作や権限は host app 側で扱います。 |
| Initial expansion | `initial_state` / `initial_expansion:` | 初期表示時にどの範囲を展開するかを表す設定です。`expanded_keys`、`collapsed_keys`、`max_initial_depth` と組み合わせます。 |
| Expanded keys | `expanded_keys:` | 初期表示時に明示的に展開するnode_key配列です。親が描画されていない子だけを指定しても表示されないため、必要に応じて祖先も含めます。 |
| Collapsed keys | `collapsed_keys:` | 初期表示時に明示的に閉じるnode_key配列です。`initial_state: :expanded` と組み合わせて、一部だけ閉じる用途に使います。 |
| Render scope | `render_scope:` / `max_render_depth` / `max_leaf_distance` | 描画対象そのものを制限する設定です。対象外nodeは初期HTMLに出ず、開閉対象としても扱わない用途を想定します。 |
| Toggle scope | `toggle_scope:` / `TreeView::ToggleScope` | 開閉操作時にどの範囲をまとめて扱うかを path builder へ渡すための設定・値オブジェクトです。 |
| Leaf distance | `max_leaf_distance` / `tree_leaf_distance` | leafを `0` として、leaf側からroot方向へ数えた最短距離です。root基準depthとは逆方向の絞り込みに使います。 |
| Hidden count | `hidden_count` / `hidden_message_builder` | 初期表示で閉じられている子孫数を示す表示用情報です。メッセージは builder で差し替えできます。 |
| Selection | `selectable:` / `selection:` | checkbox selection の描画とpayload受け渡しの機能です。一括削除や移動などの業務処理は host app 側で実装します。 |
| Selection payload | `selection_payload_builder` | checkbox value に入れるJSON payloadを作るbuilderです。既定では key / id / type を含むHashを使います。 |
| Selection visibility | `selection_visibility` | checkboxを全行、rootのみ、leafのみ、非表示のどれにするかを指定する設定です。 |
| Row class builder | `row_class_builder` | `<tr>` に付与するCSS classを返すbuilderです。行の状態表示やhost app側のスタイル連携に使います。 |
| Row data builder | `row_data_builder` | `<tr>` に付与するdata属性Hashを返すbuilderです。軽量なJS連携やテスト用hookに使います。 |
| Row event payload | `row_event_payload_builder` | drag-and-drop などの行イベントで使うpayloadを作るbuilderです。TreeView はpayloadの受け渡しまでを担当し、業務処理は host app 側に委ねます。 |
| Badge builder | `badge_builder` | nodeの件数や状態などを小さなバッジとして表示するbuilderです。 |
| Icon builder | `icon_builder` | node種別や状態を小さな視覚要素として表示するbuilderです。現在の表示slotでは `badge_builder` が優先されます。 |
| Depth label builder | `depth_label_builder` | depthを任意のラベルとして表示するbuilderです。画面上の階層把握を補助します。 |
| Row status | disabled / readonly row hooks | 行全体を disabled / readonly のように扱うための表示上の状態です。実際の権限判定や処理禁止は host app 側でも行います。 |
| Persisted state | `TreeView::PersistedState` | 開閉状態などを復元するための値オブジェクトです。主に `tree_instance_key` と `expanded_keys` を持ちます。 |
| State store | `TreeView::StateStore` | optional persistence の保存・取得を支援する小さなAPIです。DB設計やownerの決定はhost app側に残します。 |
| Tree diagnostics | diagnostics helpers | expanded keys、統計、orphan node など、ツリー構造を確認するための補助API群です。 |
