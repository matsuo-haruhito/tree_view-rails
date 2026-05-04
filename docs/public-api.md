# Public API

This document describes which APIs host applications can rely on directly, which parts are intentionally internal, and how compatibility is handled.

## Stable public entry points

Host applications may use these entry points directly:

- `TreeView.configure`
- `TreeView.configuration`
- `TreeView.reset_configuration!`
- `TreeView.parse_selection_params`
- `TreeView.node_key`
- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::GraphAdapter`
- `TreeView::PathTree`
- `TreeView::ReverseTree`
- `tree_view_rows(render_state)`

## Public option surface

The public option surface includes documented keyword arguments and grouped options for these objects:

- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`

Options documented in `docs/api.md` are treated as compatibility targets.

When an option has both a legacy flat keyword and a grouped option form, the documented priority order is part of the public contract. New options should keep that priority explicit in specs and docs.

## Host app extension points

Host applications are expected to provide these pieces:

- records or adapter data
- row partials through `row_partial`
- path builders for Turbo mode
- optional row class and data builders
- optional selection payload and disabled builders
- optional hidden message, breadcrumb, depth label, and row status builders

Builder return values are public contracts when they are documented in `docs/api.md` or a feature-specific doc.

## CSS and JavaScript surface

The public browser-facing surface is intentionally narrower than the internal implementation.

Stable enough for host apps to use:

- documented CSS class names intended for styling hooks
- documented `data-tree-view-*` attributes intended for integration hooks
- documented JavaScript event names and event detail payload keys

Internal by default:

- private controller methods
- undocumented CSS helper classes
- undocumented `data-*` attributes
- DOM structure details that are not mentioned in docs

When a CSS class, data attribute, or JavaScript event becomes a recommended integration point, document it before relying on it from host apps.

## Internal rendering details

Partials under `app/views/tree_view/` are part of the gem rendering implementation.

Host applications can rely on the documented behavior, but should avoid depending on private local variable names inside those partials.

The supported extension point is the host-provided `row_partial`, not monkey-patching gem partial locals.

## Breaking change criteria

Treat these as breaking changes:

- removing or renaming a documented class, module, helper, or method
- removing or renaming a documented option
- changing a documented default in a way that changes rendered output or parsed params
- changing the documented priority between flat options and grouped options
- changing documented JavaScript event names or payload keys
- removing documented CSS/data hooks intended for host app integration
- changing `tree_view_rows(render_state)` so existing documented render states no longer render

These are usually not breaking changes:

- adding optional keyword arguments with backward-compatible defaults
- adding new CSS classes while keeping documented classes
- adding new data attributes
- adding new event detail keys while keeping existing keys
- refactoring internal helper classes without changing documented behavior
- changing docs structure while preserving links from README and `docs/README.md`

## Deprecation policy

When a breaking change is useful but not urgent:

1. Keep the existing API working.
2. Add the replacement API and document it.
3. Add a deprecation note in `CHANGELOG.md` and the relevant docs.
4. Keep the compatibility path until the next minor release when practical.

For the pre-`1.0` line, breaking changes are still possible, but they should be deliberate and documented. Prefer compatibility shims when the maintenance cost is small.

## Compatibility policy

Public APIs should remain backward compatible within a minor version when possible.

If a breaking change is required, document it in `CHANGELOG.md` with a migration note.

Every PR that changes the public surface should update at least one of:

- `README.md`
- `docs/api.md`
- this document
- a feature-specific document under `docs/`
- `CHANGELOG.md`
