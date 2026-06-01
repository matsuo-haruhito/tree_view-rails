# Drag and Drop

This page explains how host apps can use TreeView transfer payloads to build drag-and-drop UI.

## Overview

TreeView does not implement drag-and-drop business behavior itself.

TreeView provides:

- hooks for rendering row transfer payloads as data attributes
- the `tree-view-transfer` controller
- helper behavior for putting payloads into `DataTransfer` on drag start
- a minimal transfer boundary so host apps can read payloads at drop targets

The host app remains responsible for drop targets, saving reordered rows, changing parents, authorization, validation, Turbo Stream updates, and error handling.

## Row transfer payload

Pass `row_event_payload_builder` to return the payload that should be transferred during drag/drop behavior.

Despite its historical name, `row_event_payload_builder` is transfer-specific. It is not a generic payload hook for every row event. See [Public Name Decisions](public-name-decisions.md).

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_event_payload_builder: ->(document) {
    {
      key: tree.node_key_for(document),
      id: document.id,
      type: document.class.name
    }
  }
)
```

The return value must be hash-like.

## View example

```erb
<tbody data-controller="tree-view-transfer">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

When rows need `draggable` or `dragstart` actions, add those attributes from the host app row partial or row data builder.

```ruby
row_data_builder: ->(document) {
  {
    action: "dragstart->tree-view-transfer#start",
    draggable: "true"
  }
}
```

## Interactive controls inside draggable rows

Rows that are draggable can still contain host-app controls such as links, buttons, inputs, selects, textareas, and `contenteditable` labels. TreeView ignores drag start events that originate from those native interactive controls so that using the control does not accidentally start a row transfer.

For custom widgets that are not native controls, add a TreeView marker to the widget or an ancestor inside the row.

```erb
<td>
  <span data-tree-view-interactive="true">Custom picker</span>
</td>
```

Use `data-tree-view-ignore-drag="true"` when only drag start should be ignored and other TreeView behaviors may still apply.

```erb
<td>
  <span data-tree-view-ignore-drag="true">Drag-safe widget</span>
</td>
```

See [Usage](usage.md#interactive-controls-inside-rows) for keyboard and row interaction markers.

For static visual references, use [drag-interactive-controls.html](../mockups/drag-interactive-controls.html) for draggable rows that mix native controls with `data-tree-view-interactive` or `data-tree-view-ignore-drag`, and [interactive-marker-behaviors.html](../mockups/interactive-marker-behaviors.html) when you need the broader comparison across keyboard, row-click, and drag markers.

## Drop behavior

Drop targets are implemented by the host app.

```js
function onDrop(event) {
  const payload = JSON.parse(event.dataTransfer.getData("application/json"))
  // Use payload.id, payload.key, and payload.type in host-app behavior.
}
```

Host apps can also listen for the public transfer events dispatched by the `tree-view-transfer` controller instead of reading controller internals directly.

```js
document.addEventListener("tree-view-transfer:drop", (event) => {
  const { sourcePayload, targetPayload, position } = event.detail
  // Apply host-app authorization, ordering, persistence, and error handling here.
})
```

The transfer controller exposes these reader-facing details:

| Event | Main `event.detail` fields | Meaning |
|---|---|---|
| `tree-view-transfer:drag-start` | `sourcePayload`, `sourceRow` | A draggable TreeView row started a transfer and its payload was copied to `DataTransfer` when available. |
| `tree-view-transfer:drag-over` | `targetPayload`, `targetRow`, `position` | The pointer is over a valid target row. TreeView reports the target payload and coarse drop position. |
| `tree-view-transfer:drop` | `sourcePayload`, `targetPayload`, `position`, `targetRow` | A payload was dropped on a target row. Host apps decide whether the requested move is allowed and how to persist it. |
| `tree-view-transfer:invalid-payload` | `value`, `row` | A target row's `data-tree-transfer-payload` could not be parsed as JSON. |
| `tree-view-transfer:invalid-transfer` | `value` | The transferred JSON value from `DataTransfer` could not be parsed. |

`position` is a TreeView-owned coarse cue for where the pointer sits inside the target row: the top third is `before`, the middle third is `inside`, and the bottom third is `after`. Treat it as input to host-app business rules, not as final authorization or persistence policy. For example, a host app may ignore `inside` for leaf-only trees, reject drops across projects, or translate `before` / `after` into an ordering update.

### Missing or invalid source payloads

Source payload availability is separate from host-app move validation.

When `DataTransfer` is missing or does not contain `application/json` or `text/plain`, TreeView leaves `sourcePayload` as `null` on the `tree-view-transfer:drop` event. This covers cases such as an external drag source, an empty transfer value, or a browser event where no transferable TreeView row payload was available. The host app should treat `sourcePayload: null` as an untrusted or unsupported move and decide the final rejection copy, logging, and UI response.

When `DataTransfer` contains a non-empty value but that value cannot be parsed as JSON, TreeView dispatches `tree-view-transfer:invalid-transfer` with the raw `value` and still leaves the source payload unavailable. That event is an integration signal, not a business-level authorization result.

When a source payload is present and valid, the host app still owns final validation. For example, it may reject a drop because the current user lacks permission, the target project is different, the target row cannot accept children, or the requested `before` / `after` / `inside` position is not allowed.

For the full JavaScript event contract, see [JavaScript event contract](js-events.md#transfer-events).

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| row transfer payload builder validation | yes | provides builder |
| transfer data attributes | yes | consumes them |
| dragstart helper | yes | wires action |
| interactive-control drag-start guard | yes | marks custom widgets when needed |
| transfer event detail | yes | listens and applies business behavior |
| source payload parse failure | reports `invalid-transfer` for non-empty invalid JSON | decides user-facing rejection, logging, and recovery |
| missing source payload | reports `sourcePayload: null` on drop | rejects or handles unsupported drops according to host-app policy |
| coarse drop position | reports `before`, `inside`, or `after` | decides whether the position is allowed and how to persist it |
| drop target | no | yes |
| reorder / move persistence | no | yes |
| authorization | no | yes |
| validation | no | yes |
| Turbo Stream update | no | yes |
| error handling | no | yes |

## Design policy

TreeView is responsible for safely exposing which node was dragged.

The host app decides where items can be dropped and how parent/child relationships or ordering should change after drop, because those rules are application-specific.