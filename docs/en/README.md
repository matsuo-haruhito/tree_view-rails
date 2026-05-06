# tree_view documentation

This is the English documentation entry point for `tree_view`.

The top-level README stays short. Detailed installation, usage, API, design, and release guidance lives under `docs/`.

## Language status

Documentation is being migrated to language-specific directories before the `0.1.0` release.

- [Japanese documentation](../ja/README.md)
- [Documentation i18n audit](../i18n-audit.md)

Not every page has a complete English translation yet. English coverage is prioritized for entry points, installation, minimal usage, usage, and API overview first.

## For users

If you are integrating TreeView into a Rails host app, start with these documents.

| Document | Description |
|---|---|
| [Installation](installation.md) | Gemfile, CSS, importmap, Propshaft / Sprockets, and development setup |
| [Minimal usage](minimal-usage.md) | Minimal controller, view, and row partial setup in a host app |
| [Usage](usage.md) | Tree basics, static rendering, Turbo rendering, RenderState, and view examples |
| [Cookbook](cookbook.md) | Common patterns composed from existing APIs |
| [API overview](api-overview.md) | Overview of the main public APIs |
| [API reference](api.md) | Main public APIs, options, behavior, and constraints |
| [Glossary](glossary.md) | Main terms used in TreeView docs and code |
| [Node keys](node-keys.md) | node_key design, collision avoidance, and validation |
| [Tree diagnostics](tree-diagnostics.md) | Structure inspection APIs for node keys, DOM IDs, orphans, and cycles |
| [Selection](selection.md) | Checkbox selection, visibility, and submitted value parsing |
| [Lazy Loading](lazy-loading.md) | Hooks and data attributes for loading children on demand |
| [Windowed Rendering](windowed-rendering.md) | Opt-in API for rendering visible rows by offset / limit |
| [Persisted State](persisted-state.md) | Persisting and restoring expansion state with the generator |
| [Breadcrumb](breadcrumb.md) | Helper for rendering ancestor paths as breadcrumbs |
| [Depth Labels](depth-labels.md) | Hook for displaying node depth labels |
| [Row Status](row-status.md) | Hook for disabled / readonly row state |
| [Filtered Trees](filtered-trees.md) | APIs for rendering search or filter results as trees |
| [Rendering Boundaries](rendering-boundaries.md) | Rendering responsibility boundaries between TreeView and host apps |
| [Render Scale](render-scale.md) | Guidance for controlling HTML and rendering volume for large trees |
| [Host App Extension Points](host-app-extension-points.md) | Hooks host apps can use to extend and integrate TreeView |
| [Drag and Drop](drag-and-drop.md) | Drag-and-drop integration boundary using row event payloads |
| [Children Pagination](children-pagination.md) | Server-side children pagination guidance for lazy loading |

## For maintainers

| Document | Description |
|---|---|
| [Public API](../public-api.md) | APIs host apps may use directly and compatibility policy |
| [Release checklist](../release.md) | Release tests, documentation, and gem package checklist |
| [Design policy](design-policy.md) | Gem responsibilities, included scope, excluded scope, and design decisions |
| [Development](development.md) | Tests, CI, documentation updates, and future work |
| [Code quality](code-quality.md) | Lint, tests, error messages, and documentation quality policy |

## Reading order

For first-time usage, read [Installation](installation.md), [Minimal usage](minimal-usage.md), and [Usage](usage.md) in that order.

For a high-level API entry point, read [API overview](api-overview.md) first, then use [API reference](api.md) for details.

For common API combinations, see [Cookbook](cookbook.md).

When TreeView terminology or identifier design is unclear, see [Glossary](glossary.md), [Node keys](node-keys.md), and [Tree diagnostics](tree-diagnostics.md).

For translation priority and bilingual readiness, see [Documentation i18n audit](../i18n-audit.md).
