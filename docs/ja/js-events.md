# JavaScript event contract

TreeView の Stimulus controller は、host app が controller 内部実装に依存せずに business behavior を接続できるよう、小さな公開 event surface を提供します。

公開 TreeView event は Stimulus `dispatch` 経由で発火するため、次の性質を持ちます。

- `tree-view-<controller>:<name>` 形式の名前を使う
- controller element から bubble する
- cancelable である
- 公開 payload は `event.detail` に入る

ここに書かれていない field は内部実装詳細として扱ってください。

listener や browser assertion で関連する documented DOM hook 名も必要な場合は、raw attribute string を写経する代わりに `tree_view/index.js` の `TreeViewIntegrationHooks` を使ってください。代表的な key は `TreeViewIntegrationHooks.state.viewKeyValue`、`TreeViewIntegrationHooks.state.nodeKey`、`TreeViewIntegrationHooks.remoteState.childrenUrl`、`TreeViewIntegrationHooks.transfer.payload` です。

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
| `selectedValues` | Array<String> | checked かつ enabled な checkbox の raw value。 |
| `selectedPayloads` | Array<Object> | checked かつ enabled な checkbox value を JSON parse した payload。invalid JSON は除外されます。 |

### `tree-view-selection:selected`

selection controller の `submit` / `refresh` action から発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `payloads` | Array<Object> | selected row の JSON payload。 |

### `tree-view-selection:limit-exceeded`

`max_count` を超える選択が試みられたときに発火します。

`event.detail` は `maxCount`, `attemptedCount`, `attemptedChecked`, `checkbox` を含みます。

### `tree-view-selection:invalid-payload`

checkbox value を JSON parse できないときに発火します。

`event.detail` は `value` と `checkbox` を含みます。

## Remote state events

### `tree-view-remote-state:change`

row が `loading`, `loaded`, `error` に変更されたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `row` | Element | remote state が変わった row。 |
| `state` | String | `loading`, `loaded`, `error` のいずれか。 |
| `childrenUrl` | String or null | `data-tree-children-url` の値。存在しなければ `null`。 |
| `nodeKey` | String or null | `data-tree-view-state-node-key` の値。存在しなければ `null`。 |

### `tree-view-remote-state:retry`

remote row の retry が要求されたときに発火します。

`event.detail` は `row`, `childrenUrl`, `nodeKey` を含みます。

## Transfer events

### `tree-view-transfer:drag-start`

TreeView row の drag が開始されたときに発火します。

`event.detail` は `sourcePayload` と `sourceRow` を含みます。

### `tree-view-transfer:drag-over`

valid な target row 上で drag している間に発火します。

`event.detail` は `targetPayload`, `targetRow`, `position` を含みます。

### `tree-view-transfer:drop`

payload が target row に drop されたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | `DataTransfer` から parse した payload。 |
| `targetPayload` | Object or null | target row の `data-tree-transfer-payload` から parse した payload。 |
| `position` | String | `before`, `inside`, `after` のいずれか。 |
| `targetRow` | Element | drop 先の row。 |

### `tree-view-transfer:invalid-payload` / `tree-view-transfer:invalid-transfer`

row payload JSON または transferred JSON を parse できないときに発火します。

## 互換性方針

machine-readable public API manifest は、このページで文書化している event name、代表的な必須 `event.detail` key、documented integration hook 名を写して drift を検知するための guard です。一次の契約は引き続きこのページです。

上記の event name と documented `detail` fields は公開 integration point です。minor release では field 追加は許容します。event 削除、field rename、documented field の意味変更は互換性に影響する変更として扱い、changelog で明示してください。
