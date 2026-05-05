# Selection

TreeView can render checkbox cells for selecting nodes.

## Overview

Selection lets host apps render checkboxes for TreeView nodes and pass checked values to forms or JavaScript behavior.

TreeView is responsible for:

- rendering checkbox cells
- generating JSON payloads for checkbox values
- controlling checkbox visibility for rendered rows
- rendering disabled checkboxes and disabled reasons
- collecting checked payloads through the JavaScript controller
- updating cascade and indeterminate state for rendered rows
- dispatching max-count exceeded events

The host app remains responsible for deleting, moving, relating, API calls, authorization, and business-specific messages.

## Minimal setup

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    checkbox_name: "selected_nodes[]",
    visibility: :leaves
  }
)
```

## Visibility

Use `selection[:visibility]` to control which rows render checkboxes.

| value | meaning |
|---|---|
| `:all` | Render checkboxes for all rendered nodes. |
| `:roots` | Render checkboxes only for root rows in the current rendered tree. |
| `:leaves` | Render checkboxes only for rows whose children are empty in the current rendered tree. |
| `:none` | Render no checkboxes while keeping empty selection cells. |

The default is `:all`.

When `selection[:enabled]` is `false`, TreeView does not render selection cells at all. When selection is enabled but a row is outside the configured visibility, TreeView renders an empty selection cell to keep table columns aligned.

## Parsing submitted values

The checkbox value is a JSON string. Host apps can parse submitted values with:

```ruby
selected_nodes = TreeView.parse_selection_params(params[:selected_nodes])
```

`TreeView.parse_selection_params` accepts arrays of JSON strings and returns parsed hash-like values. Invalid JSON raises a clear error so the host app can handle malformed submissions.

## Disabled checkboxes

Use `disabled_builder` when some nodes cannot be selected.

```ruby
selection: {
  enabled: true,
  disabled_builder: ->(document) { document.archived? },
  disabled_reason_builder: ->(document) {
    document.archived? ? "Cannot select archived documents" : nil
  }
}
```

The return value from `disabled_reason_builder` is rendered as the checkbox `title` and `data-tree-selection-disabled-reason`.

## JavaScript selection API

`tree-view-selection` can collect checked node payloads from rendered selection checkboxes.

```erb
<tbody data-controller="tree-view-selection">
  <%= tree_view_rows(@render_state) %>
</tbody>

<button data-action="tree-view-selection#submit">
  Process selected nodes
</button>
```

When `submit` runs, the controller dispatches a `tree-view-selection:selected` event.

```js
document.addEventListener("tree-view-selection:selected", (event) => {
  console.log(event.detail.payloads)
})
```

When the controller connects or selection changes, it dispatches `tree-view-selection:change`.

```js
document.addEventListener("tree-view-selection:change", (event) => {
  const { selectedCount, selectedValues, selectedPayloads } = event.detail
})
```

Only checked and enabled `.tree-selection-checkbox` elements are included. Invalid JSON values are skipped and reported through `tree-view-selection:invalid-payload`.

## Selection max count

Host apps can limit the number of checked boxes on the JavaScript controller.

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-max-count-value="10">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

When a user exceeds the limit, TreeView unchecks the attempted checkbox and dispatches `tree-view-selection:limit-exceeded`.

```js
document.addEventListener("tree-view-selection:limit-exceeded", (event) => {
  const { maxCount, attemptedCount } = event.detail
})
```

The controller reports the limit event only. Business-specific messaging and API behavior remain the host app's responsibility.

## Linked checkbox behavior

The Stimulus controller can also update rendered child rows and parent mixed states.

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-cascade-value="true"
  data-tree-view-selection-indeterminate-value="true">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

This behavior is DOM-based. It affects rendered rows only and skips disabled checkboxes.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| Rendering checkboxes | yes | no |
| JSON payload generation | yes | optional customization |
| Submitted value parsing | helper provided | owns controller behavior |
| Cascade / indeterminate | rendered DOM only | decides unloaded/server-side semantics |
| Max count event | dispatches event | shows message or blocks business action |
| Delete / move / relate / API calls | no | yes |
| Authorization | no | yes |
