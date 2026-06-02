# tree_view documentation

This is the English documentation entry point for `tree_view`.

The top-level README stays short. Detailed installation, usage, API, design, and release guidance lives under `docs/`.

## Language status

Documentation now lives in language-specific directories, and bilingual coverage is tracked as an ongoing maintenance task after the `0.1.0` release.

- [Japanese documentation](../ja/README.md)
- [Documentation i18n audit](../i18n-audit.md)

Most user-facing, feature, release, and maintainer pages now exist in both language trees. When English detail lags behind Japanese wording, track that mismatch through the i18n audit rather than treating the English tree as entry-point-only coverage.

## For users

If you are integrating TreeView into a Rails host app, start with these documents.

### Goal-based shortcuts

| Goal | Start here |
|---|---|
| Set up TreeView for the first time | [Installation](installation.md), then [Minimal usage](minimal-usage.md) and [Usage](usage.md) |
| Choose the right API or rendering mode | [Decision guide](decision-guide.md), then [API overview](api-overview.md) and [API reference](api.md) |
| Render large or partial trees | [Render Scale](render-scale.md), [Lazy Loading](lazy-loading.md), [Windowed Rendering](windowed-rendering.md), and [Children Pagination](children-pagination.md) |
| Wire selection, forms, or table-owned columns | [Selection](selection.md), [Forms and editing rows](form-editing.md), and [Resource table bridge](resource-table-bridge.md) |
| Check public contracts and integration hooks | [Public API](public-api.md), [JavaScript event contract](js-events.md), and [Host App Extension Points](host-app-extension-points.md) |
| Diagnose symptoms or responsibility boundaries | [Troubleshooting](troubleshooting.md), [FAQ](faq.md), and [Tree diagnostics](tree-diagnostics.md) |

| Document | Description |
|---|---|
| [Installation](installation.md) | Gemfile, CSS, importmap, Propshaft / Sprockets, and development setup |
| [Minimal usage](minimal-usage.md) | Minimal controller, view, and row partial setup in a host app |
| [Usage](usage.md) | Tree basics, static rendering, Turbo rendering, RenderState, and view examples |
| [Toolbar helper](toolbar.md) | `tree_view_toolbar`, expand/collapse actions, the `:current_path` contract, and the toolbar visual reference |
| [Turbo Frame option](turbo-frame.md) | Target TreeView Turbo toggle links at a host-app Turbo Frame without custom JavaScript |
| [Localized names](localized-names.md) | Resolve model, attribute, and node type labels through ActiveModel / I18n |
| [Decision guide](decision-guide.md) | Use-case flowchart and table for choosing the right API or option, including GraphAdapter adapter mode |
| [FAQ](faq.md) | Short answers about responsibility boundaries, query expectations, and common misunderstandings |
| [Troubleshooting](troubleshooting.md) | Symptom-based entry point for common integration problems before diving into API-specific pages |
| [Visual reference mockups](../mockups/README.md) | Static HTML/CSS references for baseline output and interaction states without running a Rails app. Start with [review-gallery.html](../mockups/review-gallery.html) for the fastest side-by-side first look, open [default-tree.html](../mockups/default-tree.html) when you want the baseline DOM structure and shared CSS reference directly, then use the mockup index for the focused pages and each page's role. |
| [Accessibility Semantics](accessibility-semantics.md) | First-class accessibility guidance for table-first rows, ARIA placement, keyboard boundaries, and host-app responsibilities |
| [Cookbook](cookbook.md) | Common patterns composed from existing APIs, including GraphAdapter ActiveRecord performance notes |
| [NodePresenter row partial patterns](node-presenter-row-partials.md) | Use NodePresenter from host-app row partials instead of adding app-specific Column / Action DSLs |
| [Forms and editing rows](form-editing.md) | Bulk edit forms, inline-editing layouts, Form Objects, row actions, and responsibility boundaries |
| [Resource table bridge](resource-table-bridge.md) | Bridge TreeView row rendering with a separate table layer that owns columns and table state |
| [API overview](api-overview.md) | Overview of the main public APIs, including records, resolver, and GraphAdapter adapter modes |
| [API reference](api.md) | Main public APIs, options, behavior, and constraints |
| [PathTreeBuilder](path-tree-builder.md) | Build generated folder nodes and record nodes from path-like record values |
| [ReverseTree](reverse-tree.md) | Render child-to-parent paths when matched records should be roots and ancestors should appear below them |
| [Error hierarchy](errors.md) | Public TreeView error classes and rescue guidance |
| [JavaScript event contract](js-events.md) | Public Stimulus event names, detail payloads, and compatibility policy |
| [Migration guide](migration.md) | Upgrade-oriented compatibility, deprecation, rename, and release-note guidance |
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
| [Direction-aware styling boundary](direction-aware-styling.md) | Host-app override guidance and future criteria for direction-aware current-row, hierarchy connector, and toggle spacing hooks |
| [Render Scale](render-scale.md) | Guidance for controlling HTML and rendering volume for large trees |
| [Host App Extension Points](host-app-extension-points.md) | Hooks host apps can use to extend and integrate TreeView |
| [Public Name Decisions](public-name-decisions.md) | Focused decisions for confusing public-facing builder names |
| [Drag and Drop](drag-and-drop.md) | Drag-and-drop integration boundary using row event payloads |
| [Children Pagination](children-pagination.md) | Server-side children pagination guidance for lazy loading |

## For maintainers

| Document | Description |
|---|---|
| [Product Profile](../../Product%20Profile.md) | Repository positioning, source-of-truth order, maintainership boundaries, and non-goals |
| [AGENTS.md](../../AGENTS.md) | Repository-specific maintainer workflow, first-read order, and documentation update rules |
| [Root docs index](../README.md) | Cross-language docs map and maintenance entry point for durable maintainer docs |
| [CHANGELOG.md](../../CHANGELOG.md) | Release-facing summary of public changes, compatibility notes, and notable documentation additions |
| [Documentation i18n audit](../i18n-audit.md) | Cross-language sync rules, technical-asset inventory, and translation priority checks |
| [Public API](public-api.md) | APIs host apps may use directly and compatibility policy |
| [Migration guide](migration.md) | Upgrade-oriented summary of compatibility promises, deprecations, and release-note expectations |
| [Release checklist](release.md) | Release tests, documentation, and gem package checklist |
| [Design policy](design-policy.md) | Gem responsibilities, included scope, excluded scope, and design decisions |
| [Development](development.md) | Tests, CI, documentation updates, future work, and the current `npm install` exception while `package-lock.json` remains out of sync |
| [Code quality](code-quality.md) | Lint, tests, error messages, and documentation quality policy |

## Reading order

For first-time usage, read [Installation](installation.md), [Minimal usage](minimal-usage.md), and [Usage](usage.md) in that order.

When you know the use case but not the right API, start with the [Decision guide](decision-guide.md).

For common responsibility-boundary questions before choosing an API, read the [FAQ](faq.md).

When you already know the symptom but need the fastest path to the relevant page, start with [Troubleshooting](troubleshooting.md).

For tree-wide expand/collapse controls, see [Toolbar helper](toolbar.md). Use [toolbar-actions.html](../mockups/toolbar-actions.html) as the static visual companion for supported toolbar actions and the `:current_path` contract.

For static visual references of baseline DOM structure and interaction states, see [Visual reference mockups](../mockups/README.md). Start with [review-gallery.html](../mockups/review-gallery.html) for the fastest first look, open [default-tree.html](../mockups/default-tree.html) when you want the baseline DOM structure and shared CSS reference directly, then use the mockup index for the focused pages and each page's role.

For a high-level API entry point, read [API overview](api-overview.md) first, then use [API reference](api.md) for details.

For heterogeneous or graph-like nodes that do not fit one parent-id column, start with [Decision guide](decision-guide.md), then read [API overview: adapter mode](api-overview.md#adapter-mode), [API reference: TreeView::Tree](api.md#treeviewtree), and [Cookbook: GraphAdapter and ActiveRecord performance](cookbook.md#graphadapter-and-activerecord-performance) as needed.

For Turbo Frame targeting from TreeView toggle links, see [Turbo Frame option](turbo-frame.md).

For localized model, attribute, and node type labels, see [Localized names](localized-names.md).

For generated folder trees from path-like records, see [PathTreeBuilder](path-tree-builder.md).

For child-to-parent paths where matched records should become the visible roots, see [ReverseTree](reverse-tree.md).

When a separate table layer owns columns or saved table state, see [Resource table bridge](resource-table-bridge.md).

For common API combinations, see [Cookbook](cookbook.md). For row partial patterns with NodePresenter, see [NodePresenter row partial patterns](node-presenter-row-partials.md). For editing-oriented row layouts, see [Forms and editing rows](form-editing.md).

When TreeView terminology or identifier design is unclear, see [Glossary](glossary.md), [Node keys](node-keys.md), and [Tree diagnostics](tree-diagnostics.md).

For TreeView-specific rescue behavior, see [Error hierarchy](errors.md).

For public Stimulus event names and payloads, see [JavaScript event contract](js-events.md).

For upgrade planning, deprecations, and release-note expectations, see [Migration guide](migration.md).

For accessibility semantics, ARIA placement, and keyboard boundaries, see [Accessibility Semantics](accessibility-semantics.md).

For TreeView render log verbosity in host app logs, see [Render log level](render-log-level.md).

For host-app overrides of current-row cues, hierarchy connectors, toggle spacing, and future direction-aware styling hook criteria, see [Direction-aware styling boundary](direction-aware-styling.md).

For translation priority and bilingual readiness, see [Documentation i18n audit](../i18n-audit.md).