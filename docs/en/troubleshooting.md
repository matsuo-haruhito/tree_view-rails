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

- [Render log silencing](render-log-silencing.md)
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

Read next:

- [Lazy Loading](lazy-loading.md)
- [Children Pagination](children-pagination.md)
- [JavaScript event contract](js-events.md)

## Selection payloads are missing or not what the host app expects

Selection checkboxes submit JSON strings, not plain IDs.

Check these points.

- Parse submitted values with `TreeView.parse_selection_params` on the server side.
- In JavaScript, remember that TreeView only reports checked and enabled checkboxes.
- Invalid JSON payloads are omitted from the selected payload array and reported through `tree-view-selection:invalid-payload`.
- Use grouped `selection:` options for row payload generation, disabled-state decisions, and checkbox visibility.
- If the tree sits inside a regular form, configure `data-tree-view-selection-hidden-input-name-value` on the `tree-view-selection` host element so checked payloads are mirrored into hidden inputs.
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

Read next:

- [Persisted State](persisted-state.md)
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
