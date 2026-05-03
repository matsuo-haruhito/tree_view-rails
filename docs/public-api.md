# Public API

This document describes which APIs host applications can rely on directly.

## Stable public entry points

Host applications may use these entry points directly:

- `TreeView.configure`
- `TreeView.configuration`
- `TreeView.reset_configuration!`
- `TreeView.parse_selection_params`
- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::GraphAdapter`
- `TreeView::PathTree`
- `TreeView::ReverseTree`
- `tree_view_rows(render_state)`

## Host app extension points

Host applications are expected to provide these pieces:

- records or adapter data
- row partials through `row_partial`
- path builders for Turbo mode
- optional row class and data builders
- optional selection payload and disabled builders

## Internal rendering details

Partials under `app/views/tree_view/` are part of the gem rendering implementation.
Host applications can rely on the documented behavior, but should avoid depending on private local variable names inside those partials.

## Compatibility policy

Public APIs should remain backward compatible within a minor version when possible.

If a breaking change is required, document it in `CHANGELOG.md` with a migration note.
