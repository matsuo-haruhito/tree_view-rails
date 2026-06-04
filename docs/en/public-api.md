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
- `TreeView::NodePresenter`
- `TreeView::PathTree`
- `TreeView::PathTreeBuilder`
- `TreeView::ReverseTree`
- `TreeView::PersistedState`
- `TreeView::StateStore`
- `TreeView::Diagnostics`
- `tree_view_rows(render_state)`
- `tree_view_rows(render_state, window: { offset:, limit: })`
- `tree_view_window(render_state, offset:, limit:)`
- `tree_node_dom_id(item_or_id, ui: @tree_ui)`
- `tree_children_container_dom_id(item_or_id, ui: @tree_ui)`
- `tree_remote_state_placeholder_dom_id(item_or_id, ui: @tree_ui)`
- `tree_remote_state_placeholder_attributes(item_or_id, state: nil, ui: @tree_ui)`
- `tree_selection_value(item, tree, builder = nil)`
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
- `tree_children_container_dom_id(item, ui: @tree_ui)` builds the stable children-container DOM ID used by lazy-loading host-app placeholder regions.
- `tree_remote_state_placeholder_dom_id(item, ui: @tree_ui)` builds the stable remote-state placeholder DOM ID for one row.
- `tree_remote_state_placeholder_attributes(item, state: nil, ui: @tree_ui)` returns the documented placeholder `id` and optional `data-tree-remote-state` attribute for host-app lazy-loading responses.
- `tree_selection_value(item, tree, builder = nil)` serializes the documented checkbox payload contract for host-app selection wiring and assertions.
- `tree_view_breadcrumb(tree, item, ...)` renders a breadcrumb path for a node.

For host apps that own lazy-loading placeholder regions, these three lazy-loading helpers are part of the same stable helper surface described in [Lazy Loading](lazy-loading.md). Use them instead of reconstructing placeholder IDs or `data-tree-remote-state` attributes by hand.

For app-owned toolbar builders, use `tree_view_toolbar_supported_actions`, `tree_view_toolbar_actions`, and `tree_view_toolbar_action_metadata` rather than internal constants.
Documented toolbar helpers are part of that public helper surface:

- `tree_view_toolbar(render_state, actions: ..., labels: ..., class_name: ..., button_class_name: ..., html: ..., action_html: ...)` renders TreeView's bundled toolbar markup and accepts documented additive HTML attributes for the toolbar container and action elements.
- `tree_view_toolbar_supported_actions` returns the supported toolbar action symbols for app-owned toolbar builders.
- `tree_view_toolbar_actions(render_state, actions: ..., labels: {})` returns action hashes so the host app can render its own toolbar markup.
- `tree_view_toolbar_action_metadata(render_state, action, label: nil)` returns metadata for one supported action.

`html:` adds container attributes such as `class`, `data`, or `aria` while preserving TreeView's required toolbar data hook. `action_html:` adds attributes to each action link or disabled button through an action-aware Proc, action-keyed Hash, or flat Hash while preserving TreeView's required action and disabled data hooks. Use custom rendering helpers when the host app needs different markup, authorization copy, or additional controls.

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

`TreeView.configure`, `TreeView.configuration`, and `TreeView.reset_configuration!` are the stable configuration entry points. Depend on documented option names and behavior rather than the internal shape of the configuration object. See [Render log level](render-log-level.md) for the `render_log_level` values, default, disable path, and host-app logging boundary.

Documented localized display-name helpers include:

- `TreeView.model_name_for(item_or_class, count: 1, default: nil)`
- `TreeView.attribute_name_for(item_or_class, attribute, default: nil)`
- `TreeView.type_name_for(item, count: 1, default: nil)`

Localized display-name helpers resolve labels through the host app's Rails / ActiveModel / I18n locale data when available, then fall back to humanized names or an explicit `default:` value. They only return display names; host app row partials, helpers, or presenters still decide where those names appear in the UI. See [Localized names](localized-names.md) for fallback behavior and row-rendering examples.

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
| `toggle_icons` | `by_state`, `by_depth`, `by_type` | Mirrors the documented declarative toggle icon map. `toggle_icon_builder` remains a callable escape hatch and is not manifest-backed. |
| `selection` | `enabled`, `visibility`, `payload_builder`, `checkbox_name`, `disabled_builder`, `disabled_reason_builder`, `selected_keys`, `cascade`, `indeterminate`, `max_count` | Mirrors `TreeView::RenderState::SelectionConfig` and keeps grouped selection wiring aligned with the documented flat selection keywords. |
| `lazy_loading` | `enabled`, `loaded_keys`, `scope` | Mirrors the documented lazy-loading row-state hooks and optional host-app scope passthrough. |
| `row_status` | `row_disabled_builder`, `row_readonly_builder`, `row_disabled_reason_builder` | Mirrors the documented row disabled / readonly state hooks and disabled-reason surface. |

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
- `TreeViewEventDetailKeys`
- `TreeViewTransferDropPositions`
- `TreeViewControllerIdentifiers`
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
`TreeViewEventDetailKeys` exposes the documented `event.detail` key lists as a machine-readable package-root export. Use it when host-app tests or listeners need to compare against the documented key names without changing the payload shape; the field meanings still live in [JavaScript event contract](js-events.md).
`TreeViewTransferDropPositions` exposes the documented coarse drop-position values for transfer events: `before`, `inside`, and `after`. `TreeViewEventNames.transfer.*` names transfer events, `TreeViewEventDetailKeys.transfer.*` lists the documented `event.detail` keys, and `TreeViewTransferDropPositions` carries the position values described in [Drag and Drop](drag-and-drop.md#drop-behavior).
`TreeViewControllerIdentifiers` exposes the same documented identifiers as a machine-readable object. Host apps that selectively register controllers or choose a custom boot order should use this export instead of hand-copying identifier strings.

Within `TreeViewEventNames`, lazy-loading request lifecycle names live under `hostLifecycle`:

- `loading`
- `loaded`
- `error`
- `retry`

Use `TreeViewEventNames.hostLifecycle.*` only for the host-app dispatch surface described in [Lazy Loading](lazy-loading.md). TreeView's own controller-emitted remote-state events remain under `TreeViewEventNames.remoteState.*`.

Documented keys on `TreeViewControllerIdentifiers`:

- `state`
- `client`
- `selection`
- `transfer`
- `remoteState`

The `tree-view-selection` controller's documented host-element value attributes are also part of the stable host-app wiring surface:

- `data-tree-view-selection-hidden-input-name-value`
- `data-tree-view-selection-max-count-value`
- `data-tree-view-selection-cascade-value`
- `data-tree-view-selection-indeterminate-value`

Use those attributes when configuring the controller on the host element. Use the `selection:` render-state builders for row payload generation, disabled-state decisions, and checkbox visibility. See [Selection](selection.md) and [Host app extension points](host-app-extension-points.md#selection-builders).

The machine-readable source of truth for the package-root JavaScript exports and bundled controller identifiers lives in `config/public_api_manifest.yml`. The compatibility spec and entrypoint smoke check read that contract to detect drift.

Internal by default:

- private controller methods
- file layout under `app/javascript/tree_view/`
- undocumented `data-*` attributes outside the documented host-app wiring surface
- DOM traversal details inside controllers

## CSS and DOM surface

Host apps may rely on documented CSS classes, data attributes, and JavaScript events intended as integration hooks.

`data-turbo-frame` emitted from configured Turbo toggle links is part of the documented host-app integration surface.

Representative documented hooks are tracked where their feature behavior is explained:

| Hook area | Representative hooks | Contract boundary |
|---|---|---|
| Toolbar | `data-tree-view-toolbar`, `data-tree-view-toolbar-action`, `data-tree-view-toolbar-disabled` | TreeView-owned hooks documented in [Toolbar](toolbar.md). Use helper methods for supported actions and metadata instead of internal constants. |
| Selection | `data-tree-view-selection-hidden-input-name-value`, `data-tree-view-selection-max-count-value`, `data-tree-view-selection-cascade-value`, `data-tree-view-selection-indeterminate-value` | Stable host-element controller values documented in [Selection](selection.md). Row payloads and disabled decisions stay with `selection:` render-state builders. |
| Lazy loading | `data-tree-remote-state`, remote placeholder IDs, lazy-loading lifecycle events | Stable placeholder and event hooks documented in [Lazy Loading](lazy-loading.md). Host apps still own request dispatch and response handling. |
| Empty state | `data-tree-view-empty-state`, `.tree-view-empty-row__content`, `.tree-view-empty-row__message` | Reusable baseline hooks documented in the [mockup inventory](../mockups/README.md). They describe the shipped empty-state reference pattern, not every internal row class. |
| Interaction markers | marker row classes and `data-*` hooks shown in focused mockups | Reference hooks documented through [mockups](../mockups/README.md) for review and adoption. Promote any hook to a machine-readable contract in `config/public_api_manifest.yml` only when it needs compatibility checks. |

This inventory is intentionally representative, not exhaustive. `config/public_api_manifest.yml` remains the machine-readable source of truth for helper methods, JavaScript package-root exports, controller identifiers, and RenderState grouped option keys. Docs-only hook inventories should point to feature guides and mockups; they should not turn every emitted class or `data-*` attribute into a compatibility contract.

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
