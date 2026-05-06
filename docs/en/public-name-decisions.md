# Public name decisions

This page records focused public-facing naming decisions before `0.1.0`.

## `badge_builder` and `icon_builder`

Use `badge_builder` as the recommended hook for row badge or marker display.

`icon_builder` remains as a compatibility alias for existing callers. Internally, `RenderContext#badge_builder` may still fall back to `icon_builder` when `badge_builder` is not configured, but new docs and examples should not recommend `icon_builder`.

If TreeView adds toggle-specific visual customization, it should use a separate, toggle-specific hook such as `toggle_icon_builder` so TreeView can continue to own the toggle link or button structure, ARIA attributes, Turbo attributes, and keyboard behavior.

## `row_event_payload_builder`

`row_event_payload_builder` is transfer-specific. It should return the hash-like payload that TreeView serializes for drag/drop transfer data.

It is not a generic event payload hook for every row event. Host apps that need unrelated row events should wire their own data attributes and Stimulus actions through `row_data_builder` or their row partials.

## `loading_builder` and `error_builder`

`loading_builder` and `error_builder` are boolean predicates for remote row state. They do not build UI.

Each callable should return `true` only when the row should be marked as that state. Any other value is treated as false by the renderer.

## Accessibility semantics

TreeView is table-first with tree-like row controls. See [Accessibility Semantics](accessibility-semantics.md) for ARIA placement and row selection semantics.
