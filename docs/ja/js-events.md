# JavaScript event contract

TreeView の Stimulus controller は、host app が controller 内部実装に依存せずに business behavior を接続できるよう、小さな公開 event surface を提供します。

公開 TreeView event は Stimulus `dispatch` 経由で発火するため、次の性質を持ちます。

- `tree-view-<controller>:<name>` 形式の名前を使う
- controller element から bubble する
- cancelable である
- 公開payloadは `event.detail` に入る

ここに書かれていないfieldは内部実装詳細として扱ってください。

host app 側の listener や test で machine-readable な参照先が必要な場合は、`tree_view/index.js` から `TreeViewEventNames`、`TreeViewEventDetailKeys`、`TreeViewEventDetailValues` を import してください。前者は event name string の写経を避けるため、2つ目は公開されている `event.detail` key 一覧を参照するため、3つ目は選択された `event.detail` field の documented enum-like value を参照するための export です。

## State events

### `tree-view-state:state-changed`

state controller が現在の expanded-state snapshot を公開するときに発火します。初回 connect、`refresh`、expand/collapse 更新時も含みます。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `viewKey` | String or null | `data-tree-view-state-view-key-value` の値。host app はこれを保存先の `tree_instance_key` とそろえて扱えます。 |
| `expandedKeys` | Array<String> | state controller が追跡している row から収集した、現在 expanded な node key 一覧。 |

## Selection events

### `tree-view-selection:change`

checkbox selection が refresh または toggle されたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `selectedCount` | Number | checked かつ enabled な TreeView selection checkbox の数。 |
| `selectedValues` | Array<String> | checked かつ enabled な checkbox のraw value。 |
| `selectedPayloads` | Array<Object> | checked かつ enabled な checkbox valueをJSON parseしたpayload。invalid JSONは除外されます。 |

### `tree-view-selection:selected`

selection controller の `submit` / `refresh` action から発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `payloads` | Array<Object> | selected row のJSON payload。 |

### `tree-view-selection:limit-exceeded`

`max_count` を超える選択が試みられたときに発火します。

`event.detail` は `maxCount`, `attemptedCount`, `attemptedChecked`, `checkbox` を含みます。

### `tree-view-selection:invalid-payload`

checkbox value をJSON parseできないときに発火します。

`event.detail` は `value` と `checkbox` を含みます。

## Remote state events

### `tree-view-remote-state:change`

row が `loading`, `loaded`, `error` に変更されたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `row` | Element | remote state が変わったrow。 |
| `state` | String | `loading`, `loaded`, `error` のいずれか。documented value 一覧は `TreeViewEventDetailValues.remoteState.change.state` からも参照できます。 |
| `childrenUrl` | String or null | `data-tree-children-url` の値。存在しなければ `null`。 |
| `nodeKey` | String or null | `data-tree-view-state-node-key` の値。存在しなければ `null`。 |

### `tree-view-remote-state:retry`

remote row のretryが要求されたときに発火します。

`event.detail` は `row`, `childrenUrl`, `nodeKey` を含みます。

## Transfer events

### `tree-view-transfer:drag-start`

TreeView row のdragが開始されたときに発火します。

`event.detail` は `sourcePayload` と `sourceRow` を含みます。

### `tree-view-transfer:drag-over`

validなtarget row上でdragしている間に発火します。

`event.detail` は `targetPayload`, `targetRow`, `position` を含みます。

### `tree-view-transfer:drop`

payloadがtarget rowにdropされたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | `DataTransfer` からparseしたpayload。 |
| `targetPayload` | Object or null | target row の `data-tree-transfer-payload` からparseしたpayload。 |
| `position` | String | `before`, `inside`, `after` のいずれか。documented value 一覧は `TreeViewEventDetailValues.transfer.dragOver.position` と `TreeViewEventDetailValues.transfer.drop.position` からも参照できます。 |
| `targetRow` | Element | drop先のrow。 |

### `tree-view-transfer:invalid-payload` / `tree-view-transfer:invalid-transfer`

row payload JSON または transferred JSON をparseできないときに発火します。

## 互換性方針

machine-readable public API manifest は、このページで文書化している event name、代表的な必須 `event.detail` key、documented enum-like `event.detail` value を写して drift を検知するための guard です。一次の契約は引き続きこのページです。

package-root export の `TreeViewEventNames`、`TreeViewEventDetailKeys`、`TreeViewEventDetailValues` も、host app 側の listener / test から同じ documented contract を参照するための mirror です。

上記のevent name、documented `detail` fields、documented enum-like `detail` valuesは公開integration pointです。minor releaseではfield追加は許容します。event削除、field rename、documented fieldの意味変更、documented enum-like value の変更は互換性に影響する変更として扱い、changelogで明示してください。
