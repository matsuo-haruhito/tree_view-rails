# Immutable JavaScript package-root exports

This note explains the reader-facing contract for the literal JavaScript exports from `tree_view/index.js`.

## Contract boundary

The package-root literal exports are immutable reference constants. Host apps should use them to avoid retyping documented strings, event detail keys, controller identifiers, data hook names, transfer values, and related wiring names. They are not a host-app mutation target.

Representative immutable exports include:

- `TreeViewEventNames`
- `TreeViewEventDetailKeys`
- `TreeViewRemoteStateValues`
- `TreeViewStateChangeReasons`
- `TreeViewTransferDropPositions`
- data hook objects such as `TreeViewRemoteStateDataHooks`, `TreeViewToolbarDataHooks`, `TreeViewSelectionDataHooks`, `TreeViewSelectionCheckboxHooks`, and `TreeViewEmptyStateHooks`
- controller reference objects such as `TreeViewControllerIdentifiers`, `TreeViewControllerEntries`, and `TreeViewIntegrationHooks`

Prefer these package-root constants when host-app JavaScript, browser tests, or shared helpers need stable references to TreeView-owned strings. Do not mutate these objects, append keys to them, or treat them as configuration containers. If a host app needs different behavior, keep that behavior in host-app code and use the documented extension points.

## Guard responsibility

The runtime frozen contract is guarded by `script/test_entrypoints.mjs`, which checks the package-root exports with `Object.isFrozen` and verifies nested event-detail key lists where applicable.

The TypeScript declaration shape is a separate compile-time aid. `app/javascript/tree_view/index.d.ts` mirrors these exports with `Readonly` objects and `readonly` tuples, and declaration-shape checks such as `script/test_declaration_literal_shapes.mjs` keep that type surface aligned with the manifest-backed public shape.

Reader-facing guidance belongs in the Public API docs and related feature docs. The docs explain when host apps should reference constants such as `TreeViewEventNames`, `TreeViewEventDetailKeys`, and the data hook objects instead of retyping raw strings. That docs guidance does not change runtime values, event payload shapes, controller behavior, or the public export set.

## Related docs

- [Public API](public-api.md#javascript-surface)
- [JavaScript event contract](js-events.md)
- [Drag and Drop](drag-and-drop.md)
- [Lazy Loading](lazy-loading.md)
