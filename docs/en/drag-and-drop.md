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

## Drop behavior

Drop targets are implemented by the host app.

```js
function onDrop(event) {
  const payload = JSON.parse(event.dataTransfer.getData("application/json"))
  // Use payload.id, payload.key, and payload.type in host-app behavior.
}
```

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| row transfer payload builder validation | yes | provides builder |
| transfer data attributes | yes | consumes them |
| dragstart helper | yes | wires action |
| interactive-control drag-start guard | yes | marks custom widgets when needed |
| drop target | no | yes |
| reorder / move persistence | no | yes |
| authorization | no | yes |
| validation | no | yes |
| Turbo Stream update | no | yes |
| error handling | no | yes |

## Design policy

TreeView is responsible for safely exposing which node was dragged.

The host app decides where items can be dropped and how parent/child relationships or ordering should change after drop, because those rules are application-specific.
