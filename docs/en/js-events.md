# JavaScript event contract

TreeView's Stimulus controllers dispatch a small public event surface so host apps can attach business behavior without depending on controller internals.

Events are dispatched through Stimulus `dispatch`, so public TreeView events:

- use the `tree-view-<controller>:<name>` naming pattern
- bubble from the controller element
- are cancelable
- carry their public payload in `event.detail`

Treat fields not documented here as internal implementation details.

When host-app listeners need a machine-readable source of truth, import `TreeViewEventNames`, `TreeViewEventDetailKeys`, and `TreeViewEventDetailValues` from `tree_view/index.js`. The first avoids hand-copying event-name strings, the second exposes the documented `event.detail` key lists for each public event, and the third exposes the documented enum-like values for selected `event.detail` fields.

## State events

### `tree-view-state:state-changed`

Dispatched whenever the state controller publishes the current expanded-state snapshot, including on initial connect, `refresh`, and expand/collapse updates.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `viewKey` | String or null | Value from `data-tree-view-state-view-key-value`, when present. Host apps can align this with the persisted `tree_instance_key` they save against. |
| `expandedKeys` | Array<String> | Current expanded node keys collected from the state controller's tracked rows. |

## Selection events

### `tree-view-selection:change`

Dispatched when the current checkbox selection is refreshed or toggled.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `selectedCount` | Number | Count of checked, enabled TreeView selection checkboxes. |
| `selectedValues` | Array<String> | Raw checkbox values for checked, enabled checkboxes. |
| `selectedPayloads` | Array<Object> | Parsed JSON payloads from checked, enabled checkboxes. Invalid JSON values are omitted. |

### `tree-view-selection:selected`

Dispatched by the selection controller `submit` and `refresh` actions.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `payloads` | Array<Object> | Parsed JSON payloads for the selected rows. |

### `tree-view-selection:limit-exceeded`

Dispatched when `max_count` would be exceeded.

`event.detail` contains `maxCount`, `attemptedCount`, `attemptedChecked`, and `checkbox`.

### `tree-view-selection:invalid-payload`

Dispatched when a checkbox value cannot be parsed as JSON.

`event.detail` contains `value` and `checkbox`.

## Remote state events

### `tree-view-remote-state:change`

Dispatched when a row is marked `loading`, `loaded`, or `error`.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `row` | Element | The row whose remote state changed. |
| `state` | String | One of `loading`, `loaded`, or `error`. The documented value list is also available from `TreeViewEventDetailValues.remoteState.change.state`. |
| `childrenUrl` | String or null | Value from `data-tree-children-url`, when present. |
| `nodeKey` | String or null | Value from `data-tree-view-state-node-key`, when present. |

### `tree-view-remote-state:retry`

Dispatched when retry is requested for a remote row.

`event.detail` contains `row`, `childrenUrl`, and `nodeKey`.

## Transfer events

### `tree-view-transfer:drag-start`

Dispatched when a TreeView row drag starts.

`event.detail` contains `sourcePayload` and `sourceRow`.

### `tree-view-transfer:drag-over`

Dispatched while dragging over a valid target row.

`event.detail` contains `targetPayload`, `targetRow`, and `position`.

### `tree-view-transfer:drop`

Dispatched when a payload is dropped on a target row.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | Payload parsed from `DataTransfer`. |
| `targetPayload` | Object or null | Payload parsed from the target row's `data-tree-transfer-payload`. |
| `position` | String | `before`, `inside`, or `after`. The documented value list is also available from `TreeViewEventDetailValues.transfer.dragOver.position` and `TreeViewEventDetailValues.transfer.drop.position`. |
| `targetRow` | Element | The row receiving the drop. |

### `tree-view-transfer:invalid-payload` / `tree-view-transfer:invalid-transfer`

Dispatched when row payload JSON or transferred JSON cannot be parsed.

## Compatibility policy

The machine-readable public API manifest mirrors the event names, representative required `event.detail` keys, and documented enum-like `event.detail` values on this page so compatibility specs can detect drift; this page remains the primary contract.

The package-root exports `TreeViewEventNames`, `TreeViewEventDetailKeys`, and `TreeViewEventDetailValues` mirror that same documented contract for host-app listeners and tests.

The event names, documented `detail` fields, and documented enum-like `detail` values above are public integration points. Additive fields may be added in minor releases. Removing events, renaming fields, changing documented field meanings, or changing documented enum-like values should be treated as a compatibility-impacting change and called out in the changelog.
