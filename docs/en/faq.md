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

## Does TreeView choose the SQL or cursor strategy for children pagination?

No. TreeView does not choose the pagination algorithm, SQL shape, cursor design, ordering, or next-page checks for large child sets.

The gem provides integration boundaries through lazy-loading URLs and row hooks. The host app decides how children are fetched, paged, authorized, and rendered back.

See also:

- [Decision guide](decision-guide.md)
- [Children Pagination](children-pagination.md)
- [Lazy Loading](lazy-loading.md)
