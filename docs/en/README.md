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
| [Turbo Frame option](turbo-frame.md) | Target TreeView Turbo toggle links at a host-app Turbo Frame without custom JavaScript |
| [Decision guide](decision-guide.md) | Use-case flowchart and table for choosing the right API or option |
| [Accessibility Semantics](accessibility-semantics.md) | First-class accessibility guidance for table-first rows, ARIA placement, keyboard boundaries, and host-app responsibilities |
| [Cookbook](cookbook.md) | Common patterns composed from existing APIs |
| [NodePresenter row partial patterns](node-presenter-row-partials.md) | Use NodePresenter from host-app row partials instead of adding app-specific Column / Action DSLs |
| [Forms and editing rows](form-editing.md) | Bulk edit forms, inline-editing layouts, Form Objects, row actions, and responsibility boundaries |
| [API overview](api-overview.md) | Overview of the main public APIs |
| [API reference](api.md) | Main public APIs, options, behavior, and constraints |
| [PathTreeBuilder](path-tree-builder.md) | Build generated folder nodes and record nodes from path-like record values |
| [Error hierarchy](errors.md) | Public TreeView error classes and rescue guidance |
| [JavaScript event contract](js-events.md) | Public Stimulus event names, detail payloads, and compatibility policy |
| [Render log level](render-log-level.md) | Configure TreeView partial render log silencing in host app logs |
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
| [Public Name Decisions](public-name-decisions.md) | Focused decisions for confusing public-facing builder names |
| [Drag and Drop](drag-and-drop.md) | Drag-and-drop integration boundary using row event payloads |
| [Children Pagination](children-pagination.md) | Server-side children pagination guidance for lazy loading |

## For maintainers

| Document | Description |
|---|---|
| [Public API](public-api.md) | APIs host apps may use directly and compatibility policy |
| [Release checklist](release.md) | Release tests, documentation, and gem package checklist |
| [Design policy](design-policy.md) | Gem responsibilities, included scope, excluded scope, and design decisions |
| [Development](development.md) | Tests, CI, documentation updates, and future work |
| [Code quality](code-quality.md) | Lint, tests, error messages, and documentation quality policy |

## Reading order

For first-time usage, read [Installation](installation.md), [Minimal usage](minimal-usage.md), and [Usage](usage.md) in that order.

When you know the use case but not the right API, start with the [Decision guide](decision-guide.md).

For a high-level API entry point, read [API overview](api-overview.md) first, then use [API reference](api.md) for details.

For Turbo Frame targeting from TreeView toggle links, see [Turbo Frame option](turbo-frame.md).

For generated folder trees from path-like records, see [PathTreeBuilder](path-tree-builder.md).

For common API combinations, see [Cookbook](cookbook.md). For row partial patterns with NodePresenter, see [NodePresenter row partial patterns](node-presenter-row-partials.md). For editing-oriented row layouts, see [Forms and editing rows](form-editing.md).

When TreeView terminology or identifier design is unclear, see [Glossary](glossary.md), [Node keys](node-keys.md), and [Tree diagnostics](tree-diagnostics.md).

For TreeView-specific rescue behavior, see [Error hierarchy](errors.md).

For public Stimulus event names and payloads, see [JavaScript event contract](js-events.md).

For accessibility semantics, ARIA placement, and keyboard boundaries, see [Accessibility Semantics](accessibility-semantics.md).

For TreeView render log verbosity in host app logs, see [Render log level](render-log-level.md).

For translation priority and bilingual readiness, see [Documentation i18n audit](../i18n-audit.md).
