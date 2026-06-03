# Host app extension points

This page summarizes the main hooks host Rails apps can use to extend and integrate TreeView.

## Overview

TreeView keeps business-specific display and behavior in the host app. The gem exposes builders and partial boundaries so host apps can extend the UI without changing TreeView internals.

Main extension points:

- `row_partial`
- `row_class_builder`
- `row_data_builder`
- `badge_builder`
- `depth_label_builder`
- `row_disabled_builder`
- `row_readonly_builder`
- `row_disabled_reason_builder`
- transfer payload builders
- selection builders
- lazy loading path builders
- Turbo path builders
- `tree_view_toolbar`
- `tree_view_breadcrumb`
- `tree_view_window`
- `TreeView::PersistedState` / `TreeView::StateStore`

For focused naming decisions, including the compatibility status of `icon_builder`, see [Public Name Decisions](public-name-decisions.md).

## Hook reverse lookup

Use this table when deciding which hook owns a host-app integration point.

| Goal | Extension point | Detailed guide |
|---|---|---|
| Render business-specific cells or controls | `row_partial`; use `TreeView::NodePresenter` for shared row labels, badges, tooltips, or actions; mark custom widgets with `data-tree-view-interactive`, `data-tree-view-ignore-keyboard`, `data-tree-view-ignore-row-click`, or `data-tree-view-ignore-drag` when needed | [NodePresenter row partial patterns](node-presenter-row-partials.md), [Localized names](localized-names.md), [Usage](usage.md#interactive-controls-inside-rows), [Drag and Drop](drag-and-drop.md#interactive-controls-inside-draggable-rows) |
| Add host-app row metadata | `row_data_builder` for host-owned data attributes; TreeView merges lazy-loading, row status, transfer, and client-mode data after host data | [Row status](row-status.md), [Drag and Drop](drag-and-drop.md) |
| Mark an entire row disabled or readonly | `row_disabled_builder`, `row_readonly_builder`, and `row_disabled_reason_builder`; TreeView emits the documented row status classes and data attributes | [Row status](row-status.md) |
| Provide drag/drop transfer data | `row_event_payload_builder`; TreeView serializes the payload into `data-tree-transfer-payload`, adds `data-tree-transfer-node-key`, and the transfer controller skips rows with `data-tree-transfer-disabled="true"` | [Drag and Drop](drag-and-drop.md), [JavaScript event contract](js-events.md#transfer-events) |
| Configure selection payloads or row-level selection state | Render-state `selection:` options such as `payload_builder`, `disabled_builder`, `disabled_reason_builder`, `selected_keys`, and `visibility` | [Selection](selection.md), [Row status](row-status.md#difference-from-selection-disabled-state) |
| Configure selection controller behavior on already-rendered rows | Host-element `tree-view-selection` value attributes such as `data-tree-view-selection-hidden-input-name-value`, `data-tree-view-selection-max-count-value`, `data-tree-view-selection-cascade-value`, and `data-tree-view-selection-indeterminate-value` | [Selection](selection.md#hidden-input-sync-for-regular-form-submit), [JavaScript event contract](js-events.md#selection-events) |
| Render toolbar actions that expand, collapse, or collapse outside the current path | `tree_view_toolbar`, `tree_view_toolbar_supported_actions`, and `tree_view_toolbar_action_metadata`; TreeView owns the supported action metadata and data hooks, while the host app owns labels, placement, routes, and business policy around the toolbar | [Toolbar](toolbar.md), [Public API](public-api.md#helper-methods) |
| Render breadcrumb navigation for the current node path | `tree_view_breadcrumb`; TreeView renders the path helper output, while the host app owns current-item selection, route targets, authorization, and business-specific labels | [Breadcrumb](breadcrumb.md), [Localized names](localized-names.md) |
| Persist expanded, collapsed, or current tree state across requests | `TreeView::PersistedState` and `TreeView::StateStore`; TreeView owns the normalized state object and store wrapper, while the host app owns storage scope, lifecycle, and request/session policy | [Persisted State](persisted-state.md), [Public API](public-api.md#stable-public-entry-points) |
| Render only a bounded window of rows | `tree_view_window` with `TreeView::RenderWindow`; TreeView owns the rendered window helper and range validation, while the host app owns pagination strategy, loading triggers, and surrounding table or list behavior | [Windowed Rendering](windowed-rendering.md), [Public API](public-api.md#helper-methods) |

## row_partial

Application-specific columns are rendered by the host app partial.

```ruby
row_partial: "documents/tree_columns"
```

```erb
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

Use `TreeView::NodePresenter` when multiple row partials need the same label, tooltip, badge, href, row data, or action resolver. Use [Localized names](localized-names.md) inside those resolvers when the displayed model, attribute, or node type name should follow Rails / I18n. The host app still owns the actual cells, controls, authorization, formatting, and domain-specific action wiring.

The partial can include application-owned controls such as inputs, selects, buttons, links, and inline editable labels. TreeView ignores keyboard navigation and transfer drag start when events originate from native interactive controls. For custom controls, add `data-tree-view-interactive="true"` or a narrower marker such as `data-tree-view-ignore-keyboard="true"`, `data-tree-view-ignore-row-click="true"`, or `data-tree-view-ignore-drag="true"`.

```erb
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
  <%= link_to "Edit", edit_document_path(item) %>
  <span data-tree-view-interactive="true">Custom picker</span>
</td>
```

See [Usage](usage.md#interactive-controls-inside-rows) for complete row-control examples.

For static visual comparisons of these markers, use [interactive-marker-behaviors.html](../mockups/interactive-marker-behaviors.html) to compare the broad interactive marker against the narrower keyboard, row-click, and drag markers, and [drag-interactive-controls.html](../mockups/drag-interactive-controls.html) to inspect draggable rows that mix native controls with drag-safe custom widgets.

## Row class / data builders

```ruby
row_class_builder: ->(document) {
  ["document-row", ("is-current" if document == current_document)]
},
row_data_builder: ->(document) {
  { document_id: document.id }
}
```

## Visual builders

Use `badge_builder` for row badge or marker display. `icon_builder` remains available as a compatibility alias, but new code and examples should prefer `badge_builder`.

```ruby
badge_builder: ->(document) { document.status },
depth_label_builder: ->(_document, context) { "Level #{context.depth}" }
```

## Row status builders

Use the dedicated row status builders when the host app needs to expose row-wide disabled or readonly state.

```ruby
row_disabled_builder: ->(document) { document.archived? },
row_readonly_builder: ->(document) { document.locked? },
row_disabled_reason_builder: ->(document) { document.archived? ? "archived" : nil }
```

TreeView evaluates these builders and merges the documented status classes/data attributes with `row_class_builder` and `row_data_builder`. Business rules, action blocking, and reason display remain host app responsibilities. See [Row status](row-status.md) for the full contract and selection-state comparison.

## Transfer payload builders

`row_event_payload_builder` is transfer-specific. It returns the payload serialized for drag/drop transfer data; it is not a generic row event hook.

```ruby
row_event_payload_builder: ->(document) {
  { id: document.id, key: tree.node_key_for(document) }
}
```

TreeView renders the returned payload onto each transfer-enabled row as `data-tree-transfer-payload` and includes `data-tree-transfer-node-key`. The `tree-view-transfer` controller reads those attributes when dispatching transfer events and skips rows marked with `data-tree-transfer-disabled="true"`. See [Drag and Drop](drag-and-drop.md) for row wiring, transfer events, and host-app responsibility boundaries.

## Selection builders

```ruby
selection: {
  enabled: true,
  payload_builder: ->(document) { { id: document.id, name: document.name } }
}
```

`selection:` config covers row-level payload generation, disabled-state decisions, selected keys, and checkbox visibility inside `TreeView::RenderState`.

When the host app configures the `tree-view-selection` controller on the host element, these documented value attributes are part of the stable wiring surface:

- `data-tree-view-selection-hidden-input-name-value` for hidden-input sync into the nearest form
- `data-tree-view-selection-max-count-value` for client-side selection limits
- `data-tree-view-selection-cascade-value` for rendered-row cascade behavior
- `data-tree-view-selection-indeterminate-value` for parent mixed-state updates

```erb
<tbody
  data-controller="tree-view-selection"
  data-action="change->tree-view-selection#toggle"
  data-tree-view-selection-hidden-input-name-value="selected_nodes[]"
  data-tree-view-selection-max-count-value="10"
  data-tree-view-selection-cascade-value="true"
  data-tree-view-selection-indeterminate-value="true">
  <%= tree_view_rows(@render_state) %>
</tbody>
```

Use the render-state `selection:` options for what each row means, and use the host-element value attributes for how the Stimulus controller mirrors or constrains already-rendered checkboxes. For complete event and behavior details, see [Selection](selection.md).

Selection disabled state applies to the checkbox. Row-wide disabled or readonly state belongs to the row status builders, and drag/drop transfer availability belongs to the transfer row data hooks. Use [Row status](row-status.md#difference-from-selection-disabled-state) and [Drag and Drop](drag-and-drop.md) when you need to compare those boundaries.

## Path builders

Turbo and lazy-loading URLs are provided by the host app.

```ruby
show_descendants_path_builder: ->(item, depth, scope) {
  show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
},
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
}
```

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| extension hook definitions | yes | no |
| builder invocation | yes | provides builders |
| business UI | no | yes |
| interactive-control guards | yes | marks custom widgets when needed |
| routes and controllers | no | yes |
| authorization | no | yes |
| CSS/design system | hooks only | yes |
