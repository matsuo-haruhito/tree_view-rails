# 用語集

このページでは、TreeView docs とコードで使う主な用語を整理します。

## Tree / node / item

| 用語 | 意味 |
|---|---|
| item | host app側のrecordやobject。例: `Document`, `Project`。 |
| node | TreeView上でtreeの構成要素として扱われるitem。 |
| root | parentを持たない最上位node。 |
| child | あるnodeの直接の子node。 |
| descendant | child、grandchildなど、あるnode配下のすべてのnode。 |
| ancestor | parent、grandparentなど、あるnodeの上位node。 |
| leaf | childrenを持たないnode。 |

TreeViewでは、host app側のobjectを `item` と呼び、tree構造上の役割を説明するときに `node` と呼ぶことがあります。

## key / id

| 用語 | 意味 |
|---|---|
| id | host appのrecord id。通常はdatabase id。 |
| node_key | TreeView内でnodeを識別するtree側のkey。開閉状態、selection、persisted state、row payload、diagnosticsなどで使います。 |
| UI識別子 / DOM ID | `UiConfig` / `UiConfigBuilder` 経由で生成されるブラウザ向け識別子。HTML ID、Turbo target、row属性、関連hookで使います。 |
| tree_instance_key | persisted stateを保存するときにtreeや画面を区別するkey。 |

`node_key` は、複数treeや異種nodeが同じ画面に出る場合に衝突しないように設計してください。`expanded_keys` や `collapsed_keys` などの開閉関連値は、host appが意図して同じ安定値を両方の層で使っていない限り、UIだけのDOM IDではなくtree側node keyと一致している必要があります。

## rendering

| 用語 | 意味 |
|---|---|
| RenderState | 画面単位の描画状態。tree、root_items、row_partial、ui_config、selectionなどを保持します。 |
| UiConfig | DOM IDやpath builderなど、UI描画に必要な設定。 |
| row_partial | host app固有の列を描画するpartial。 |
| visible row | 現在の展開状態やrender scopeを反映した結果、描画対象になる行。 |
| render scope | 描画対象をdepthやleaf distanceで制限する設定。 |
| toggle scope | 開閉操作の対象範囲をpath builderに渡すための設定。 |

## expansion

| 用語 | 意味 |
|---|---|
| initial_state | 初期表示時の既定展開状態。`:expanded` または `:collapsed`。 |
| expanded_keys | 初期表示時に明示的に展開するtree側node key配列。 |
| collapsed_keys | 初期表示時に明示的に折りたたむtree側node key配列。 |
| persisted state | 保存・復元される展開状態。 |

## tree variants

| 用語 | 意味 |
|---|---|
| records mode | `records` と `parent_id_method` からtreeを作るmode。 |
| resolver mode | `roots` と `children_resolver` からtreeを作るmode。 |
| adapter mode | `GraphAdapter` などのadapterでtreeを作るmode。 |
| PathTree | matched itemsの親階層をrootから補完して表示するtree。 |
| ReverseTree | matched itemからroot方向へ辿る表示用tree。 |

## responsibility boundary

| 用語 | 意味 |
|---|---|
| TreeView responsibility | gemが提供するUI primitive、helper、builder、controller hook。 |
| host app responsibility | CRUD、認可、保存、query、Turbo response、業務固有UI。 |

TreeViewはtree UIの基盤を提供し、業務仕様やアプリ固有の挙動はhost app側で実装する方針です。
