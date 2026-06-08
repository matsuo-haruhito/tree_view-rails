# JavaScript event contract

TreeView's Stimulus controllers dispatch a small public event surface so host apps can attach business behavior without depending on controller internals.

Events are dispatched through Stimulus `dispatch`, so public TreeView events:

- use the `tree-view-<controller>:<name>` naming pattern
- bubble from the controller element
- are cancelable
- carry their public payload in `event.detail`

Treat fields not documented here as internal implementation details.

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

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `maxCount` | Number | Configured selection limit from `max_count`. |
| `attemptedCount` | Number | Count that would result from the attempted toggle. |
| `attemptedChecked` | Boolean | Whether the attempted checkbox action was checking a row. |
| `checkbox` | HTMLInputElement | Checkbox that triggered the limit check. |

### `tree-view-selection:invalid-payload`

Dispatched when a checkbox value cannot be parsed as JSON.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `value` | String | Raw checkbox value that could not be parsed as JSON. |
| `checkbox` | HTMLInputElement | Checkbox whose value could not be parsed. |

## Remote state events

### `tree-view-remote-state:change`

Dispatched when a row is marked `loading`, `loaded`, or `error`. A retry action also marks the row `loading` and dispatches this event before the retry event.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `row` | Element | The row whose remote state changed. |
| `state` | String | One of `loading`, `loaded`, or `error`. |
| `childrenUrl` | String or null | Value from `data-tree-children-url`, when present. |
| `nodeKey` | String or null | Value from `data-tree-view-state-node-key`, when present. |

### `tree-view-remote-state:retry`

Dispatched when retry is requested for a remote row.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `row` | Element | The row whose remote load is being retried. |
| `childrenUrl` | String or null | Value from `data-tree-children-url`, when present. |
| `nodeKey` | String or null | Value from `data-tree-view-state-node-key`, when present. |

## Host lifecycle events

### `tree-view:loading` / `tree-view:loaded` / `tree-view:error` / `tree-view:retry`

Host apps may dispatch these lifecycle events on a lazy-loading TreeView row so the remote-state controller can mark that row as loading, loaded, error, or retrying.

These events intentionally do not define public `event.detail` fields. They are listed in `config/public_api_manifest.yml` under `event_names_without_detail` instead of `event_detail_keys`, so the entrypoint smoke can distinguish this policy from an accidental missing detail-key entry. Put row-specific remote-state data on the row attributes documented for lazy loading instead of relying on payload fields.

## Transfer events

### `tree-view-transfer:drag-start`

Dispatched when a TreeView row drag starts.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | Payload parsed from the dragged row's `data-tree-transfer-payload`. |
| `sourceRow` | Element | The row where the drag started. |

### `tree-view-transfer:drag-over`

Dispatched while dragging over a valid target row.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `targetPayload` | Object or null | Payload parsed from the target row's `data-tree-transfer-payload`. |
| `targetRow` | Element | The row currently being dragged over. |
| `position` | String | `before`, `inside`, or `after`. |

### `tree-view-transfer:drop`

Dispatched when a payload is dropped on a target row.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `sourcePayload` | Object or null | Payload parsed from `DataTransfer`. |
| `targetPayload` | Object or null | Payload parsed from the target row's `data-tree-transfer-payload`. |
| `position` | String | `before`, `inside`, or `after`. |
| `targetRow` | Element | The row receiving the drop. |

### `tree-view-transfer:invalid-payload`

Dispatched when row payload JSON cannot be parsed.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `value` | String | Raw row payload value that could not be parsed as JSON. |
| `row` | Element | Row whose payload could not be parsed. |

### `tree-view-transfer:invalid-transfer`

Dispatched when transferred JSON cannot be parsed.

`event.detail` contains:

| Field | Type | Description |
|---|---|---|
| `value` | String | Raw transferred value that could not be parsed as JSON. |

## Using TreeViewEventNames in host-app code

The raw event strings above remain the public contract. When wiring listeners in host-app JavaScript, you can import `TreeViewEventNames` from `tree_view/index.js` and use the matching package-root export instead of hand-copying strings:

```js
import { TreeViewEventNames } from "tree_view/index.js"

element.addEventListener(TreeViewEventNames.selection.change, handleSelectionChange)
element.addEventListener(TreeViewEventNames.remoteState.change, handleRemoteStateChange)
```

`TreeViewEventNames.hostLifecycle.*` is for host apps dispatching lazy-loading request lifecycle events such as `tree-view:loading`; TreeView controller-emitted remote-state events on this page use `TreeViewEventNames.remoteState.*`.

When listener code or browser assertions also need the related documented DOM hook names, import `TreeViewIntegrationHooks` from `tree_view/index.js` instead of hand-copying raw attribute strings. Representative keys are `TreeViewIntegrationHooks.state.viewKeyValue`, `TreeViewIntegrationHooks.remoteState.childrenUrl`, and `TreeViewIntegrationHooks.transfer.payload`.

`tree-view-transfer:invalid-payload` detail contains `value` and `row`.

`tree-view-transfer:invalid-transfer` detail contains `value`.

## Compatibility policy

The machine-readable public API manifest mirrors the event names, documented integration hook names, and representative required `event.detail` keys documented on this page so compatibility specs can detect drift; this page remains the primary contract. Host app tests may import `TreeViewEventDetailKeys` from the package root when they need a machine-readable list of documented detail key names without changing the event payload shape.

Every public event name in the manifest must be classified either under `event_detail_keys` when it has documented detail fields or under `event_names_without_detail` when it intentionally exposes no public detail fields. The entrypoint smoke checks that classification so host lifecycle events do not look like missing `event.detail` coverage.

The event names and documented `detail` fields above are public integration points. Additive fields may be added in minor releases. Removing events, renaming fields, or changing documented field meanings should be treated as a compatibility-impacting change and called out in the changelog.
