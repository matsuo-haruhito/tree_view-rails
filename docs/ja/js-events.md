# JavaScript event contract

TreeView の Stimulus controller は、host app が controller 内部実装に依存せずに business behavior を接続できるよう、小さな公開 event surface を提供します。

公開 TreeView event は Stimulus `dispatch` 経由で発火するため、次の性質を持ちます。

- `tree-view-<controller>:<name>` 形式の名前を使う
- controller element から bubble する
- cancelable である
- 公開payloadは `event.detail` に入る

ここに書かれていないfieldは内部実装詳細として扱ってください。

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

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `maxCount` | Number | `max_count` から設定された selection 上限。 |
| `attemptedCount` | Number | 試行された toggle 後の選択数。 |
| `attemptedChecked` | Boolean | 試行された checkbox 操作が row を check するものだったか。 |
| `checkbox` | HTMLInputElement | 上限判定を発生させた checkbox。 |

### `tree-view-selection:invalid-payload`

checkbox value をJSON parseできないときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `value` | String | JSON parse できなかった raw checkbox value。 |
| `checkbox` | HTMLInputElement | value を parse できなかった checkbox。 |

## Remote state events

### `tree-view-remote-state:change`

row が `loading`, `loaded`, `error` に変更されたときに発火します。retry action も row を `loading` に戻し、retry event の前にこの event を発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `row` | Element | remote state が変わったrow。 |
| `state` | String | `loading`, `loaded`, `error` のいずれか。 |
| `childrenUrl` | String or null | `data-tree-children-url` の値。存在しなければ `null`。 |
| `nodeKey` | String or null | `data-tree-view-state-node-key` の値。存在しなければ `null`。 |

### `tree-view-remote-state:retry`

remote row のretryが要求されたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `row` | Element | remote load を retry する row。 |
| `childrenUrl` | String or null | `data-tree-children-url` の値。存在しなければ `null`。 |
| `nodeKey` | String or null | `data-tree-view-state-node-key` の値。存在しなければ `null`。 |

## Host lifecycle events

### `tree-view:loading` / `tree-view:loaded` / `tree-view:error` / `tree-view:retry`

host app は、lazy-loading TreeView row 上でこれらの lifecycle event を発火し、remote-state controller にその row を loading、loaded、error、retrying として扱わせることができます。

これらの event は、意図的に公開 `event.detail` field を定義していません。`config/public_api_manifest.yml` では `event_detail_keys` ではなく `event_names_without_detail` に載せ、entrypoint smoke がこの方針と detail-key entry の追加漏れを区別できるようにしています。payload field に依存せず、lazy loading docs で案内している row attribute に remote-state data を置いてください。

## Transfer events

### `tree-view-transfer:drag-start`

TreeView row のdragが開始されたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | drag 元 row の `data-tree-transfer-payload` からparseしたpayload。 |
| `sourceRow` | Element | drag が開始された row。 |

### `tree-view-transfer:drag-over`

validなtarget row上でdragしている間に発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `targetPayload` | Object or null | target row の `data-tree-transfer-payload` からparseしたpayload。 |
| `targetRow` | Element | 現在 drag over している row。 |
| `position` | String | `before`, `inside`, `after` のいずれか。 |

### `tree-view-transfer:drop`

payloadがtarget rowにdropされたときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | `DataTransfer` からparseしたpayload。 |
| `targetPayload` | Object or null | target row の `data-tree-transfer-payload` からparseしたpayload。 |
| `position` | String | `before`, `inside`, `after` のいずれか。 |
| `targetRow` | Element | drop先のrow。 |

### `tree-view-transfer:invalid-payload`

row payload JSON をparseできないときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `value` | String | JSON parse できなかった raw row payload value。 |
| `row` | Element | payload を parse できなかった row。 |

### `tree-view-transfer:invalid-transfer`

transferred JSON をparseできないときに発火します。

`event.detail` は次を含みます。

| Field | Type | Description |
|---|---|---|
| `value` | String | JSON parse できなかった raw transferred value。 |

## host app code で TreeViewEventNames を使う

上記の raw event string は引き続き公開契約です。host app の JavaScript で listener を配線するときは、`tree_view/index.js` から `TreeViewEventNames` を import し、event name string を写経せずに対応する package-root export を使えます。

```js
import { TreeViewEventNames } from "tree_view/index.js"

element.addEventListener(TreeViewEventNames.selection.change, handleSelectionChange)
element.addEventListener(TreeViewEventNames.remoteState.change, handleRemoteStateChange)
```

`TreeViewEventNames.hostLifecycle.*` は、`tree-view:loading` など lazy-loading request lifecycle event を host app 側で dispatch するための surface です。このページで説明している TreeView controller 自身が emit する remote-state event は `TreeViewEventNames.remoteState.*` を使います。

`tree-view-transfer:invalid-payload` の detail は `value` と `row` を含みます。

`tree-view-transfer:invalid-transfer` の detail は `value` を含みます。

## host app code で documented event values を使う

一部の `event.detail` field は、小さな documented value set を公開します。listener の分岐や test でそれらの値が必要な場合、host app は package-root の value export を import し、string を写経せずに参照できます。

```js
import {
  TreeViewEventNames,
  TreeViewRemoteStateValues,
  TreeViewTransferDropPositions
} from "tree_view/index.js"

element.addEventListener(TreeViewEventNames.remoteState.change, (event) => {
  if (event.detail.state === TreeViewRemoteStateValues.error) showRetryNotice(event.detail.row)
})

element.addEventListener(TreeViewEventNames.transfer.drop, (event) => {
  if (event.detail.position === TreeViewTransferDropPositions.inside) attachAsChild(event.detail)
})
```

`TreeViewEventNames` は event 名、`TreeViewEventDetailKeys` は documented payload field 名、これらの value export は field に入る documented enum-like value を表します。`TreeViewRemoteStateValues` は remote-state row value (`loading`, `loaded`, `error`) に限定し、`TreeViewTransferDropPositions` は transfer drop position (`before`, `inside`, `after`) に限定します。listener helper を追加したり、controller dispatch behavior を変更したりするものではありません。

## 互換性方針

machine-readable public API manifest は、このページで文書化している event name と代表的な必須 `event.detail` key を写して drift を検知するための guard です。一次の契約は引き続きこのページです。host app の test が documented detail key 名の machine-readable な一覧を必要とする場合は、event payload shape を変えずに package root の `TreeViewEventDetailKeys` を import できます。

manifest 上のすべての public event name は、documented detail field を持つ場合は `event_detail_keys`、意図的に公開 detail field を持たない場合は `event_names_without_detail` のどちらかに分類します。entrypoint smoke はこの分類を確認するため、host lifecycle events が `event.detail` coverage の追加漏れに見えないようになります。

上記のevent nameとdocumented `detail` fieldsは公開integration pointです。minor releaseではfield追加は許容します。event削除、field rename、documented fieldの意味変更は互換性に影響する変更として扱い、changelogで明示してください。