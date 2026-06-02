# Troubleshooting

This page is a symptom-based entry point for common TreeView integration problems.

Use it when you already know what is going wrong in the host app, but are not sure which API page to open first.

TreeView provides rendering primitives, JavaScript hooks, and validation helpers. The host app still owns routes, controller actions, authorization, queries, Turbo Stream responses, business actions, and layout decisions.

## Toggle links do not expand or collapse

Check the tree mode first.

- `build_turbo` / `build` expects host-app Turbo Stream endpoints.
- `build_static` renders a snapshot only. Collapsed descendants are not present in the browser, so nothing can be opened client-side.
- `build_client_side` expects descendants to already exist in the initial HTML and uses TreeView JavaScript to show or hide them.

Then confirm the matching wiring.

- Turbo mode: verify `show_descendants_path_builder`, `hide_descendants_path_builder`, routes, controller actions, authorization, and Turbo Stream responses in the host app.
- Client-side mode: verify TreeView controllers are registered and the tree root renders `tree_view_state_data(@render_state)`.
- Lazy loading cannot be combined with client-side toggle mode.

Read next:

- [Usage](usage.md)
- [Turbo Frame option](turbo-frame.md)
- [Lazy Loading](lazy-loading.md)
- [Installation](installation.md)

## Toolbar actions render as disabled buttons

Toolbar actions become disabled buttons when TreeView cannot build a path for that action. This is usually a host-app routing or state contract issue, not a toolbar styling issue.

Check these points.

- Confirm the render state was built with a `UiConfig` that responds to `toggle_all_path`.
- In Turbo mode, pass `toggle_all_path_builder:` to `build_turbo` so `UiConfig#toggle_all_path(state:)` can return a path for `:expanded`, `:collapsed`, and any optional `:current_path` action.
- If a single action is disabled, confirm the host app builder returns a non-`nil` path for that action's state value.
- For `collapse_all_except_current_path`, confirm the host app has a clear `:current_path` policy and knows which branch should remain open.
- Keep route, authorization, Turbo Stream response, and expanded-key persistence checks in the host app; TreeView only emits the toolbar action and target state.

Read next:

- [Toolbar helper](toolbar.md)
- [Turbo Frame option](turbo-frame.md)
- [Usage](usage.md)

## Breadcrumbs fail or cannot find a parent path

Breadcrumb path lookup is records-mode only. TreeView can render breadcrumbs when it can walk `parent_id_method` relationships from the current record back to a root.

Check these points.

- Confirm the tree was built from `records:` with `parent_id_method:`. Resolver mode and adapter mode do not expose a unique parent path to the bundled breadcrumb helper.
- If the error says parent path helpers are only supported in records mode, keep the failure as a mode boundary signal instead of trying to infer parents from graph-like data.
- If the data is graph-like, has multiple possible parents, or comes from `GraphAdapter`, let the host app choose the breadcrumb trail and render its own links or labels.
- Keep route, authorization, layout placement, and analytics behavior in the host app; TreeView only owns records-mode path lookup and helper HTML.

Read next:

- [Breadcrumb](breadcrumb.md#supported-mode)
- [GraphAdapter](graph-adapter.md)
- [Host App Extension Points](host-app-extension-points.md)
- [Rendering Boundaries](rendering-boundaries.md)

## Row partial output looks broken or table cells do not line up

TreeView owns the row wrapper and common tree UI cells. The host app owns the contents of `row_partial`, action cells, and the surrounding table layout.

Check these points in order.

- Confirm the page-level table wrapper belongs to the host app and is consistent with the row partial.
- Confirm the row partial renders the business columns the page expects.
- If selection, resource-table bridging, or other optional cells are enabled, make sure the host app layout still expects those extra cells.
- If the problem appears only for specific records, inspect node keys and DOM IDs before changing the partial blindly.

Read next:

- [Rendering Boundaries](rendering-boundaries.md)
- [Resource table bridge](resource-table-bridge.md)
- [Selection](selection.md)
- [Accessibility Semantics](accessibility-semantics.md)
- [Tree diagnostics](tree-diagnostics.md)

## Tree rendering triggers repeated queries or high ActiveRecord time

Treat this as a host-app data loading and row partial problem first. TreeView can traverse the tree and render rows, but it does not choose eager-loading, authorization, caching, or derived-value strategies for application records.

Check these signals in the Rails log while rendering the tree.

- `ActiveRecord:` time is high compared with `Views:` time.
- Similar `Document Load`, `DocumentVersion Load`, or application-specific query lines repeat while rows render.
- Repeated queries are not marked `CACHE`.
- The row partial calls helpers or associations that perform database work for every row.

Then move the expensive work out of the render loop.

- Materialize parent records before building the tree.
- Return arrays, not lazy ActiveRecord relations, from `GraphAdapter` `children_resolver` callbacks.
- Cache child collections by parent id in the host app.
- Precompute authorization, version, or display metadata before the row partial renders.

Read next:

- [Cookbook: GraphAdapter and ActiveRecord performance](cookbook.md#graphadapter-and-activerecord-performance)
- [Rendering Boundaries](rendering-boundaries.md)
- [Tree diagnostics](tree-diagnostics.md)

## CSS or JavaScript integration does not seem to apply

Start with installation wiring.

- Import the stylesheet with `@import "tree_view";`.
- Add the importmap pin when JavaScript-powered features are needed: `pin "tree_view", to: "tree_view/index.js"`.
- Register TreeView controllers in the host app when using client-side toggling, selection, transfer hooks, remote loading state, or other browser-side features.
- When the host app registers only some controllers or chooses a custom boot order, import `TreeViewControllerIdentifiers` from `tree_view/index.js` instead of hand-copying identifier strings.

Remember the boundary.

- Static rendering can work without TreeView JavaScript.
- Selection cascade, client-side expand/collapse, transfer events, and remote loading state need the JavaScript controllers.
- Missing CSS usually means the host app stylesheet pipeline was not wired to load the gem asset.

Read next:

- [Installation](installation.md)
- [Usage](usage.md)
- [JavaScript event contract](js-events.md)

## TreeView partial render logs are missing or too noisy

TreeView lowers the log level around helper-rendered partials by default. That is intentional and only affects partial rendering that goes through TreeView helpers.

Check these points.

- `TreeView.configuration.render_log_level` defaults to `:warn`.
- Set `TreeView.configure { |config| config.render_log_level = :info }` or `:debug` when you want more render visibility while inspecting row partial wiring.
- Set `TreeView.configure { |config| config.render_log_level = nil }` when you want Rails render logs to remain unchanged.
- If changing `render_log_level` has no effect, confirm the host app logger responds to `silence`; otherwise TreeView falls back to normal rendering without wrapping the logger.
- If the missing or noisy lines come from controller, SQL, or business logs, adjust the host app logging policy instead of expecting TreeView to change them.

Read next:

- [Render log level](render-log-level.md)
- [Usage](usage.md)
- [Rendering Boundaries](rendering-boundaries.md)

## Lazy loading does not replace children or remote state stays stuck

Lazy loading is Turbo/server-driven.

Check these points.

- Confirm `load_children_path_builder` is present on the `UiConfig`.
- Confirm `lazy_loading: { enabled: true }` is set on `RenderState`.
- Confirm the host app endpoint returns the subtree or placeholder region it owns.
- Confirm the host app keeps `loaded_keys` in sync so already-loaded rows are rendered as loaded on the next response.
- Confirm the page is not using `build_client_side` together with lazy loading.

If the row shows loading or error state but never settles, inspect the host-app request/response lifecycle rather than the row partial first.

When the host app listens for retry or remote-state events, also confirm the browser-side detail matches the row wiring.

- `tree-view-remote-state:retry` carries `row`, `childrenUrl`, and `nodeKey` in `event.detail`.
- `childrenUrl` comes from the row's `data-tree-children-url` attribute.
- `nodeKey` comes from the row's `data-tree-view-state-node-key` attribute.
- If either value is `null`, inspect the rendered row attributes before changing retry handling.

Read next:

- [Lazy Loading](lazy-loading.md)
- [Children Pagination](children-pagination.md)
- [JavaScript event contract](js-events.md#tree-view-remote-stateretry)

## Selection payloads are missing or not what the host app expects

Selection checkboxes submit JSON strings, not plain IDs.

Check these points.

- Parse submitted values with `TreeView.parse_selection_params` on the server side.
- In JavaScript, remember that TreeView only reports checked and enabled checkboxes.
- Invalid JSON payloads are omitted from the selected payload array and reported through `tree-view-selection:invalid-payload`.
- Use grouped `selection:` options for row payload generation, disabled-state decisions, and checkbox visibility.
- If a user can check boxes but a regular HTML form submit sends no selection params, configure `data-tree-view-selection-hidden-input-name-value` on the `tree-view-selection` host element. Listening for `tree-view-selection:selected` or `tree-view-selection:change` alone does not create form params.
- Hidden input sync writes one hidden input per valid checked payload to the nearest form. If the tree is outside the form, TreeView still dispatches selection events but does not create hidden inputs.
- Disabled checkboxes and invalid JSON payloads are skipped for hidden inputs, matching the JavaScript event payload behavior.
- When one form contains multiple trees, use separate hidden input names when the server should receive separate params. Reuse a name only when the host app intentionally accepts one combined array; TreeView uses source ids only to keep each controller from removing another controller's generated inputs.
- If you expect client-side max-count limits or linked checkbox behavior, configure `data-tree-view-selection-max-count-value`, `data-tree-view-selection-cascade-value`, and `data-tree-view-selection-indeterminate-value` on the same host element.
- Cascade and indeterminate behavior only affects rendered rows in the current DOM.

Read next:

- [Selection](selection.md)
- [Host App Extension Points](host-app-extension-points.md)
- [Public API](public-api.md)
- [JavaScript event contract](js-events.md)

## Persisted state does not save or restore as expected

Persisted state is split between gem helpers and host-app policy.

Check these points.

- Run the install generator and review the generated model and migration.
- Make sure the owner model includes the generated owner concern when needed.
- Use a stable `tree_instance_key` per screen or per tree placement.
- Confirm the host app save endpoint chooses the owner, authorizes the request, and calls `StateStore` or `TreeView::PersistedStateController` correctly.
- If explicit `expanded_keys` are passed into `RenderState`, they override the persisted state.
- If a browser listener saves immediately on page load, remember that `tree-view-state:state-changed` is also dispatched on initial connect. Treat the first event as the current expanded-state snapshot, then debounce, ignore the first event, or use a host-app dirty-state policy when only user-initiated saves should be sent.
- If the same `expandedKeys` snapshot is saved repeatedly, inspect the host-app listener before changing TreeView. TreeView publishes state changes; the host app owns autosave timing, duplicate suppression, retry behavior, authorization, and endpoint responses.
- For the detailed browser wiring boundary, read the practical notes in [Persisted State](persisted-state.md#browser-event-wiring).

Read next:

- [Persisted State](persisted-state.md)
- [JavaScript event contract](js-events.md)
- [Tree diagnostics](tree-diagnostics.md)

## Duplicate node keys, orphan records, DOM ID collisions, or cycles appear

These are data-shape or identifier problems first.

Check these points.

- Enable `validate_node_keys: true` when building the tree.
- Choose `orphan_strategy:` intentionally for filtered or permission-scoped datasets.
- Call `render_state.validate_unique_dom_ids!` in development, tests, or pre-release checks.
- Use `TreeView::CycleDiagnostics.new(tree).report` when parent relationships may contain invalid loops.

Read next:

- [Tree diagnostics](tree-diagnostics.md)
- [Error hierarchy](errors.md)
- [Node keys](node-keys.md)

## When the problem is really host-app scope

Open the host-app code first when the issue depends on:

- queries or filtering policy
- authorization
- controller actions or routes
- Turbo Stream response shape
- business actions after selection or drag/drop
- table design, captions, or page layout

TreeView documents these responsibility boundaries on purpose so the gem stays reusable.

Read next:

- [Rendering Boundaries](rendering-boundaries.md)
- [FAQ](faq.md)
- [Design policy](design-policy.md)