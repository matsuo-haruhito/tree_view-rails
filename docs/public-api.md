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
- `TreeView::VisibleRows`
- `TreeView::RenderWindow`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::GraphAdapter`
- `TreeView::PathTree`
- `TreeView::ReverseTree`
- `TreeView::PersistedState`
- `TreeView::StateStore`
- `tree_view_rows(render_state)`
- `tree_view_rows(render_state, window: { offset:, limit: })`
- `tree_view_window(render_state, offset:, limit:)`
- `tree_view_breadcrumb(tree, item, ...)`

## Public helper surface

The supported helper surface is the documented helper method names exposed by `TreeViewHelper` and related helper modules.

Stable helper entry points include:

- row rendering helpers such as `tree_view_rows` and `tree_view_window`
- DOM/path helpers such as `tree_node_dom_id`, `tree_button_dom_id`, `tree_show_button_dom_id`, `tree_hide_descendants_path`, `tree_show_descendants_path`, and `tree_load_children_path`
- selection helpers such as `tree_selection_value`, `tree_selection_checked?`, and `tree_selection_visible?`
- row data helpers such as `tree_row_classes`, `tree_row_data`, `tree_render_row_data`, and `tree_row_transfer_data`
- rendering scope helpers such as `tree_render_children?`, `tree_render_leaf_distance?`, `tree_toggle_scope`, and `tree_branch_info`
- visual helpers such as `tree_hidden_count_message`, `tree_depth_label`, `tree_node_badge`, and `tree_toggle_label`
- breadcrumb helpers documented in `docs/breadcrumb.md`

The current internal module split under `TreeViewHelper` is not itself a public extension point. Host applications should include `TreeViewHelper` rather than including implementation modules such as `TreeViewHelper::Rendering`, `TreeViewHelper::Selection`, `TreeViewHelper::Transfer`, or `TreeViewHelper::LazyLoading` directly.

The helper module names may change as long as the documented helper methods keep their behavior.

## Public option surface

The public option surface includes documented keyword arguments and grouped options for these objects:

- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::RenderWindow`
- `TreeView::PersistedState`
- `TreeView::StateStore`

Options documented in `docs/api.md` are treated as compatibility targets.

When an option has both a legacy flat keyword and a grouped option form, the documented priority order is part of the public contract. New options should keep that priority explicit in specs and docs.

## Host app extension points

Host applications are expected to provide these pieces:

- records or adapter data
- row partials through `row_partial`
- path builders for Turbo mode
- optional row class and data builders
- optional row event payload builders
- optional selection payload and disabled builders
- optional hidden message, breadcrumb, depth label, and row status builders
- optional lazy loading path builders and remote-state handling
- optional persisted state storage model through the generator or an equivalent owner-side implementation

Builder return values are public contracts when they are documented in `docs/api.md` or a feature-specific doc.

The supported rendering extension point is the host-provided `row_partial`. Host applications should not rely on private local variables inside gem partials unless those locals are documented.

## JavaScript surface

The public JavaScript entrypoint is `tree_view/index.js`.

Stable enough for host apps to use:

- `registerTreeViewControllers(application)`
- exported controller classes:
  - `TreeViewStateController`
  - `TreeViewSelectionController`
  - `TreeViewTransferController`
  - `TreeViewRemoteStateController`
- documented JavaScript event names and event detail payload keys
- documented `data-tree-view-*` attributes intended for integration hooks

Internal by default:

- private controller methods
- controller file layout under `app/javascript/tree_view/`
- undocumented `data-*` attributes
- DOM traversal details used inside controllers

The controller files may be refactored as long as `tree_view/index.js` continues to export the documented names and registration helper.

## CSS and DOM surface

The public browser-facing surface is intentionally narrower than the internal implementation.

Stable enough for host apps to use:

- documented CSS class names intended for styling hooks
- documented `data-tree-view-*` attributes intended for integration hooks
- documented JavaScript event names and event detail payload keys

Internal by default:

- undocumented CSS helper classes
- undocumented `data-*` attributes
- DOM structure details that are not mentioned in docs
- private locals used by gem partials

When a CSS class, data attribute, or JavaScript event becomes a recommended integration point, document it before relying on it from host apps.

## Internal rendering details

Partials under `app/views/tree_view/` are part of the gem rendering implementation.

Host applications can rely on the documented behavior, but should avoid depending on private local variable names inside those partials.

The supported extension point is the host-provided `row_partial`, not monkey-patching gem partial locals.

`tree_view/tree_window_row` is an implementation partial for windowed rendering. Host applications should use `tree_view_rows(render_state, window: ...)` or `tree_view_window(...)` rather than rendering that partial directly.

## Semi-public advanced APIs

Some APIs are useful for advanced integrations but are more sensitive to internal behavior:

- `TreeView::VisibleRows` for inspecting currently visible rows
- `TreeView::RenderWindow` for pagination/window metadata
- tree diagnostics helpers documented in `docs/tree-diagnostics.md`
- `TreeView::DomIdValidator`
- `TreeView::CycleDiagnostics`

These APIs should stay stable when documented, but changes may be more likely than with the primary rendering API. Prefer documenting concrete use cases and adding specs before expanding their behavior.

## Internal APIs

The following are implementation details unless a specific method is documented elsewhere:

- helper implementation modules under `TreeViewHelper::*`
- `TreeView::RenderContext`
- `TreeView::RowContext`
- `TreeView::RenderTraversal`
- private methods on helpers and controllers
- generated partial locals not described in docs
- controller file layout under `app/javascript/tree_view/`

Internal APIs may be refactored without a deprecation period when documented behavior is preserved.

## Breaking change criteria

Treat these as breaking changes:

- removing or renaming a documented class, module, helper, or method
- removing or renaming a documented option
- changing a documented default in a way that changes rendered output or parsed params
- changing the documented priority between flat options and grouped options
- changing documented JavaScript event names or payload keys
- removing documented CSS/data hooks intended for host app integration
- changing `tree_view_rows(render_state)` so existing documented render states no longer render
- changing `tree_view_rows(render_state, window: ...)` so documented offset/limit behavior changes
- changing the shape of documented selection or row event payloads
- changing persisted state parsing or storage semantics documented in `docs/persisted-state.md`

These are usually not breaking changes:

- adding optional keyword arguments with backward-compatible defaults
- adding new CSS classes while keeping documented classes
- adding new data attributes
- adding new event detail keys while keeping existing keys
- refactoring internal helper modules without changing documented helper behavior
- moving controller implementation files while keeping `tree_view/index.js` exports stable
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
