# FAQ

This page answers common expectation-setting questions about what TreeView does, and what the host Rails app still owns.

## Does TreeView reduce database queries by itself?

No. TreeView's render controls decide which already-known rows are expanded, visible, or emitted as HTML. They do not reduce host-app queries or fetched records by themselves.

When query volume is the problem, move to host-app-controlled data-loading patterns such as lazy loading or children pagination.

See also:

- [Decision guide](decision-guide.md)
- [Render Scale](render-scale.md)
- [Lazy Loading](lazy-loading.md)
- [Children Pagination](children-pagination.md)

## Does `TreeView::RenderWindow` fetch less data?

No. `TreeView::RenderWindow` and `tree_view_rows(..., window:)` slice rows that are already visible in the current render state. They reduce HTML output only.

Use windowed rendering when the tree data is already available but rendering every visible row would produce too much HTML. If the expensive part is fetching children, use lazy loading or children pagination in the host app instead.

See also:

- [Decision guide](decision-guide.md)
- [Render Scale](render-scale.md)

## Does TreeView provide full virtual scrolling or infinite scroll?

No. Scroll-position-driven DOM virtualization and infinite-scroll behavior stay in the host app or an external JavaScript layer.

TreeView can still be part of that setup by providing row rendering, metadata, and hooks, but it does not ship a built-in virtual scrolling engine.

See also:

- [Decision guide](decision-guide.md)
- [Render Scale](render-scale.md)
- [Host App Extension Points](host-app-extension-points.md)

## Does TreeView provide full keyboard navigation or `treegrid` semantics?

No. TreeView provides table-based row markup with expansion controls, selection state, row-level ARIA state, and lightweight focus styling for toggle actions. It does not currently provide a full WAI-ARIA treegrid role model, roving tabindex, page-level focus order, or shortcut behavior.

Host apps own keyboard flow, captions, surrounding controls, shortcuts, and any full treegrid interaction model they choose to add.

See also:

- [Accessibility semantics](accessibility-semantics.md)
- [Host App Extension Points](host-app-extension-points.md)

## Can I use TreeView as a CRUD file manager out of the box?

Not by itself. TreeView is a rendering primitive for tree and tree-table interfaces, not a complete file-manager application.

The host app still owns records, controllers, forms, routes, authorization, labels, context menus, bulk actions, and persistence. You can build a CRUD-oriented file manager with TreeView, but those product behaviors live outside the gem.

See also:

- [README](../../README.md#out-of-scope)
- [Rendering Boundaries](rendering-boundaries.md)
- [Forms and editing rows](form-editing.md)

## Does TreeView handle authorization or policy checks?

No. Authorization remains a host-app responsibility.

TreeView can call host-app path builders and render host-app row partials, but route access, policy checks, filtered queries, and Turbo responses belong to the application.

See also:

- [README](../../README.md#out-of-scope)
- [Rendering Boundaries](rendering-boundaries.md)
- [Host App Extension Points](host-app-extension-points.md)

## Why do rows look duplicated, disappear, or fail before rendering?

Start with tree diagnostics before changing the row partial or JavaScript wiring. Duplicate node keys can make expansion and persisted state look unstable, orphan records can appear when filtering or permission scopes hide parents, DOM ID collisions can break browser-facing targets, and cycles can make parent-path traversal invalid.

Use the focused pre-render checks when a test targets one risk: `validate_node_keys: true`, `orphan_strategy:`, `render_state.validate_unique_dom_ids!`, `TreeView::CycleDiagnostics.new(tree).report`, or `tree.stats` for large-tree strategy review. Use `TreeView::Diagnostics.run` when you want one aggregate result with errors and warnings from multiple checks.

TreeView reports the risk. The host app still owns data correction, filtering policy, authorization scope, and the chosen large-tree rendering strategy.

See also:

- [Tree diagnostics](tree-diagnostics.md)
- [Troubleshooting](troubleshooting.md#duplicate-node-keys-orphan-records-dom-id-collisions-or-cycles-appear)
- [Node keys](node-keys.md)

## Why does persisted state save as soon as the page loads?

The `tree-view-state:state-changed` event is dispatched on initial connect as well as after `refresh` and expand/collapse updates. The first event is a snapshot of the current expanded state, not proof that the user changed the tree.

TreeView only publishes the event. If your host app should save only user-initiated changes, debounce the listener, ignore the first event, or gate saves behind a dirty-state policy in the host app.

See also:

- [Persisted State](persisted-state.md)
- [JavaScript event contract](js-events.md)
- [Troubleshooting](troubleshooting.md)

## Does TreeView choose the SQL or cursor strategy for children pagination?

No. TreeView does not choose the pagination algorithm, SQL shape, cursor design, ordering, or next-page checks for large child sets.

The gem provides integration boundaries through lazy-loading URLs and row hooks. The host app decides how children are fetched, paged, authorized, and rendered back.

See also:

- [Decision guide](decision-guide.md)
- [Children Pagination](children-pagination.md)
- [Lazy Loading](lazy-loading.md)
