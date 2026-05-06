# Public API

This page describes which APIs host Rails apps may depend on directly, which parts are internal, and how compatibility is handled.

## Stable public entry points

Host apps may use these entry points directly:

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

Host apps should include `TreeViewHelper` and depend on documented helper methods. They should not directly include internal implementation modules such as `TreeViewHelper::Rendering` or `TreeViewHelper::Selection`.

Internal module names may change as long as documented helper behavior is preserved.

## Public option surface

The public option surface includes documented keyword arguments and grouped options for these objects:

- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::RenderWindow`
- `TreeView::PersistedState`
- `TreeView::StateStore`

See [API reference](api.md) for details.

## Host app extension points

Host apps are expected to provide these pieces:

- records or adapter data
- `row_partial`
- Turbo mode path builders
- row class / data builders
- row event payload builders
- selection payload / disabled builders
- hidden message / breadcrumb / depth label / row status builders
- lazy loading path builders and remote-state handling
- persisted state storage model

## JavaScript surface

The public JavaScript entrypoint is `tree_view/index.js`.

Stable enough for host apps to use:

- `registerTreeViewControllers(application)`
- exported controller classes
  - `TreeViewStateController`
  - `TreeViewSelectionController`
  - `TreeViewTransferController`
  - `TreeViewRemoteStateController`
- documented JavaScript events and payload keys
- documented `data-tree-view-*` integration hooks

Internal by default:

- private controller methods
- file layout under `app/javascript/tree_view/`
- undocumented `data-*` attributes
- DOM traversal details inside controllers

## CSS and DOM surface

Host apps may rely on documented CSS classes, data attributes, and JavaScript events intended as integration hooks.

Undocumented CSS helper classes, data attributes, DOM structure details, and gem partial locals are implementation details.

## Breaking change criteria

Treat these as breaking changes:

- removing or renaming a documented class, module, helper, or method
- removing or renaming a documented option
- changing a documented default that changes rendered output or parsed params
- changing documented priority between flat options and grouped options
- changing documented JavaScript event names or payload keys
- removing documented CSS/data hooks
- changing documented `tree_view_rows(render_state)` behavior
- changing documented selection or row event payload shapes
- changing persisted state semantics

These are usually not breaking changes:

- adding optional keyword arguments with backward-compatible defaults
- adding CSS classes while keeping documented classes
- adding data attributes
- adding event detail keys
- refactoring internal helper modules
- moving controller files while keeping `tree_view/index.js` exports stable
- changing docs structure while preserving README/docs entry links

## Deprecation policy

When a breaking change is useful but not urgent:

1. Keep the existing API working.
2. Add and document the replacement API.
3. Add a deprecation note in `CHANGELOG.md` and relevant docs.
4. Keep the compatibility path until the next minor release when practical.

Even before `1.0`, breaking changes should be intentional and include migration notes.
