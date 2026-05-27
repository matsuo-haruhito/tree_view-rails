# Public API

This page describes which APIs host Rails apps may depend on directly, which parts are internal, and how compatibility is handled.

## Stable public entry points

Host apps may use these entry points directly:

- `TreeView.configure`
- `TreeView.configuration`
- `TreeView.reset_configuration!`
- `TreeView.parse_selection_params`
- `TreeView.node_key`
- `TreeView.model_name_for`
- `TreeView.attribute_name_for`
- `TreeView.type_name_for`
- `TreeView::Error`
- `TreeView::ConfigurationError`
- `TreeView::InvalidTreeError`
- `TreeView::DuplicateNodeKeyError`
- `TreeView::CycleDetectedError`
- `TreeView::InvalidRenderWindowError`
- `TreeView::LocalizedNames`
- `TreeView::Tree`
- `TreeView::RenderState`
- `TreeView::ResourceTableRenderState.call`
- `TreeView::VisibleRows`
- `TreeView::RenderWindow`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::GraphAdapter`
- `TreeView::PathTree`
- `TreeView::PathTreeBuilder`
- `TreeView::ReverseTree`
- `TreeView::PersistedState`
- `TreeView::StateStore`
- `tree_view_rows(render_state)`
- `tree_view_rows(render_state, window: { offset:, limit: })`
- `tree_view_window(render_state, offset:, limit:)`
- `tree_view_breadcrumb(tree, item, ...)`
- `tree_view_toolbar(render_state, ...)`
- `tree_view_toolbar_supported_actions`
- `tree_view_toolbar_actions(render_state, ...)`
- `tree_view_toolbar_action_metadata(render_state, action, ...)`

Use `TreeView::ResourceTableRenderState.call` when another table layer already owns column inference and table state, and TreeView should only build the hierarchical render state. See [Resource table bridge](resource-table-bridge.md).

## Public error surface

Host apps may rescue `TreeView::Error` to handle documented TreeView validation and configuration failures separately from unrelated application errors.

`TreeView::Error` inherits from `ArgumentError` for compatibility with existing integrations. New integrations should prefer `TreeView::Error` or a documented subclass when handling TreeView-specific failures.

Documented public subclasses are listed in [Error hierarchy](errors.md).

## Public helper surface

The supported helper surface is the documented helper method names exposed by `TreeViewHelper` and related helper modules, tracked as the machine-readable helper-method contract in `config/public_api_manifest.yml`.

Host apps should include `TreeViewHelper` and depend on documented helper methods. They should not directly include internal implementation modules such as `TreeViewHelper::Rendering` or `TreeViewHelper::Selection`.

Documented non-toolbar helpers that are part of that public helper surface include:

- `tree_view_rows(render_state, window: nil)` renders TreeView rows, including opt-in windowed rendering.
- `tree_view_window(render_state, offset:, limit:)` returns documented window metadata for visible rows.
- `tree_node_dom_id(item_or_id, ui: @tree_ui)` builds node DOM IDs through the resolved `UiConfig`.
- `tree_selection_value(item, tree, builder = nil)` serializes the documented checkbox payload contract for host-app selection wiring and assertions.
- `tree_view_breadcrumb(tree, item, ...)` renders a breadcrumb path for a node.

For app-owned toolbar builders, use `tree_view_toolbar_supported_actions`, `tree_view_toolbar_actions`, and `tree_view_toolbar_action_metadata` rather than internal constants.
Documented toolbar helpers are part of that public helper surface:

- `tree_view_toolbar(render_state, actions: ..., labels: ..., class_name: ..., button_class_name: ...)` renders TreeView's bundled toolbar markup.
- `tree_view_toolbar_supported_actions` returns the supported toolbar action symbols for app-owned toolbar builders.
- `tree_view_toolbar_actions(render_state, actions: ..., labels: {})` returns action hashes so the host app can render its own toolbar markup.
- `tree_view_toolbar_action_metadata(render_state, action, label: nil)` returns metadata for one supported action.

Supported toolbar action symbols are `:expand_all`, `:collapse_all`, and `:collapse_all_except_current_path`.

These actions request tree-wide toggle states `:expanded`, `:collapsed`, and `:current_path` respectively. When the current UI mode does not expose `toggle_all_path_builder`, metadata returns `path: nil` and `disabled: true`, leaving fallback UI decisions to the host app.

Internal constants such as `TREE_VIEW_TOOLBAR_ACTIONS`, `TREE_VIEW_TOOLBAR_LABELS`, and `TREE_VIEW_TOOLBAR_STATES` are implementation details. Host apps should depend on the documented helper methods and returned metadata shape instead of referencing those constants directly.

Helper methods that are not documented in `config/public_api_manifest.yml` are not part of the public compatibility contract even if bundled partials call them internally.

Internal module names may change as long as documented helper behavior is preserved.

## Public option surface

The public option surface includes documented keyword arguments and grouped options for these objects:

- `TreeView::Configuration`
- `TreeView::Tree`
- `TreeView::PathTreeBuilder`
- `TreeView::RenderState`
- `TreeView::ResourceTableRenderState.call`
- `TreeView::UiConfig`
- `TreeView::UiConfigBuilder`
- `TreeView::RenderWindow`
- `TreeView::PersistedState`
- `TreeView::StateStore`

Documented configuration options include:

- `initial_state`
- `render_log_level`

Documented localized display-name helpers include:

- `TreeView.model_name_for(item_or_class, count: 1, default: nil)`
- `TreeView.attribute_name_for(item_or_class, attribute, default: nil)`
- `TreeView.type_name_for(item, count: 1, default: nil)`

Documented Turbo UI options include:

- `UiConfig#turbo_frame`
- `UiConfigBuilder#build_turbo(turbo_frame:)`
- `UiConfigBuilder#build(..., turbo_frame:)`

See [API reference](api.md), [Localized names](localized-names.md), and [Turbo Frame option](turbo-frame.md) for details.

### RenderState grouped option keys

`TreeView::RenderState` grouped options are part of the public option surface. The exact machine-readable key set lives in `config/public_api_manifest.yml`, and `spec/public_api_compatibility_spec.rb` checks that manifest against the current `TreeView::RenderState` constants and representative behavior.

| Group | Documented public keys | Notes |
|---|---|---|
| `initial_expansion` | `default`, `max_depth`, `expanded_keys`, `collapsed_keys`, `current_item`, `current_key`, `auto_expand_ancestors` | When flat keyword options and `initial_expansion:` are both supplied, the flat keyword options still win. |
| `render_scope` | `max_depth`, `max_leaf_distance` | Mirrors the documented render-depth and leaf-distance controls for `TreeView::RenderState`. |
| `toggle_scope` | `max_depth_from_root`, `max_leaf_distance` | Mirrors the documented tree-wide toggle depth and toggle leaf-distance controls. |
| `selection` | `enabled`, `visibility`, `payload_builder`, `checkbox_name`, `disabled_builder`, `disabled_reason_builder`, `selected_keys`, `cascade`, `indeterminate`, `max_count` | Mirrors `TreeView::RenderState::SelectionConfig` and keeps grouped selection wiring aligned with the documented flat selection keywords. |
| `lazy_loading` | `enabled`, `loaded_keys`, `scope` | Mirrors the documented lazy-loading row-state hooks and optional host-app scope passthrough. |

## Host app extension points

Host apps are expected to provide these pieces:

- records or adapter data
- path resolvers when building generated folder trees with `PathTreeBuilder`
- I18n translations for localized model, attribute, or node type display names
- `row_partial`
- Turbo mode path builders
- optional Turbo Frame targets through `turbo_frame:`
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
- `TreeViewEventNames`
- `TreeViewControllerIdentifiers`
- `TreeViewIntegrationHooks`
- exported controller classes
  - `TreeViewStateController`
  - `TreeViewClientController`
  - `TreeViewSelectionController`
  - `TreeViewTransferController`
  - `TreeViewRemoteStateController`
- documented JavaScript events and payload keys
- documented `data-tree-view-*` integration hooks

`registerTreeViewControllers(application)` registers the five controller exports above with the documented identifiers in the bundled entrypoint order.

`TreeViewEventNames` exposes the documented event names as a machine-readable package-root export. Use it when wiring host-app listeners and you want to avoid hand-copying event-name strings such as `TreeViewEventNames.selection.change` or `TreeViewEventNames.transfer.drop`.
`TreeViewControllerIdentifiers` exposes the same documented identifiers as a machine-readable object. Host apps that selectively register controllers or choose a custom boot order should use this export instead of hand-copying identifier strings.
`TreeViewIntegrationHooks` exposes the documented drag-safe interactive markers as a machine-readable object. Use it when custom widgets, browser assertions, or host-app wiring need the same documented attribute names without repeating raw strings.

Documented keys on `TreeViewControllerIdentifiers`:

- `state`
- `client`
- `selection`
- `transfer`
- `remoteState`

Documented keys on `TreeViewIntegrationHooks`:

- `interactive.marker`
- `interactive.ignoreDrag`

The machine-readable source of truth for the package-root JavaScript exports, documented integration hooks, and bundled controller identifiers lives in `config/public_api_manifest.yml`. The compatibility spec and entrypoint smoke check read that contract to detect drift.

Internal by default:

- private controller methods
- file layout under `app/javascript/tree_view/`
- undocumented `data-*` attributes
- DOM traversal details inside controllers

## CSS and DOM surface

Host apps may rely on documented CSS classes, data attributes, and JavaScript events intended as integration hooks.

`data-turbo-frame` emitted from configured Turbo toggle links is part of the documented host-app integration surface.

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
- removing a documented public error class or moving a documented error out of the `TreeView::Error` hierarchy

These are usually not breaking changes:

- adding optional keyword arguments with backward-compatible defaults
- adding CSS classes while keeping documented classes
- adding data attributes
- adding event detail keys
- adding new `TreeView::Error` subclasses for newly documented validation/configuration failures
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
