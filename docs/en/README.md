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
| [API overview](api-overview.md) | Overview of the main public APIs |
| [API reference](../api.md) | Detailed API reference; currently Japanese-first |
| [Selection](../selection.md) | Checkbox selection, visibility, and submitted value parsing |
| [Lazy Loading](../lazy-loading.md) | Hooks and data attributes for loading children on demand |
| [Windowed Rendering](../windowed-rendering.md) | Opt-in API for rendering visible rows by offset / limit |

## For maintainers

| Document | Description |
|---|---|
| [Public API](../public-api.md) | APIs host apps may use directly and compatibility policy |
| [Release checklist](../release.md) | Release tests, documentation, and gem package checklist |
| [Design policy](../design-policy.md) | Gem responsibilities, included scope, excluded scope, and design decisions |
| [Development](../development.md) | Tests, CI, documentation updates, and future work |

## Reading order

For first-time usage, read [Installation](installation.md), [Minimal usage](minimal-usage.md), and [Usage](usage.md) in that order.

For a high-level API entry point, read [API overview](api-overview.md) first, then use [API reference](../api.md) for details.

For translation priority and bilingual readiness, see [Documentation i18n audit](../i18n-audit.md).
