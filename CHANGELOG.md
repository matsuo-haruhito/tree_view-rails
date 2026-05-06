# Changelog

This changelog uses the following categories when applicable:

- `Added` for new features.
- `Changed` for changes in existing behavior.
- `Fixed` for bug fixes.
- `Deprecated` for features planned for removal.
- `Removed` for removed features.
- `Documentation` for docs-only changes.

Breaking changes and required migration notes should be called out explicitly in the relevant version section.

## Unreleased

### Changed

- Removed misleading `aria-controls` from Turbo toggle links until TreeView has a single stable controlled target.
- Clarified public builder naming decisions: prefer `badge_builder`, keep `icon_builder` as a compatibility alias, treat `row_event_payload_builder` as transfer-specific, and document `loading_builder` / `error_builder` as boolean predicates.

### Documentation

- Added accessibility semantics docs for table-first TreeView rows and ARIA placement policy.
- Added public name decision docs in Japanese and English.

## 0.1.0 - 2026-05-07

### Added

- Core tree rendering primitives for Rails applications.
- `TreeView::Tree` for parent-child records.
- `TreeView::GraphAdapter` for graph-like or heterogeneous node structures.
- `TreeView::PathTree` via `Tree#path_tree_for(items)` for rendering matched items with completed parent paths.
- `TreeView::ReverseTree` via `Tree#reverse_tree_for(items)` for rendering child-to-parent paths.
- `TreeView::RenderState` for screen-level rendering options.
- `tree_view_rows(render_state)` helper.
- `TreeView::RenderWindow` and opt-in windowed rendering through `tree_view_rows(render_state, window: { offset:, limit: })`.
- `tree_view_window(render_state, offset:, limit:)` for pagination metadata around visible rows.
- Static tree rendering.
- Turbo Stream path builder integration.
- Initial expansion controls:
  - `initial_state`
  - `expanded_keys`
  - `collapsed_keys`
  - `max_initial_depth`
- Render scope controls:
  - `max_render_depth`
  - `max_leaf_distance`
- Toggle scope controls:
  - `max_toggle_depth_from_root`
  - `max_toggle_leaf_distance`
- Grouped `RenderState` options:
  - `initial_expansion`
  - `render_scope`
  - `toggle_scope`
  - `selection`
- Row attribute builders:
  - `row_class_builder`
  - `row_data_builder`
- Row visual hooks:
  - `badge_builder`
  - `icon_builder`
- Checkbox selection support:
  - JSON payload values
  - custom checkbox name
  - per-node disabled state
  - disabled reason attributes
  - initial selected state via `selected_keys`
- Orphan handling strategies.
- Optional node key uniqueness validation.
- Optional DOM ID collision diagnostics via `RenderState#validate_unique_dom_ids!`.
- `TreeView::VisibleRows` for flattening currently visible rows with depth and expansion state.
- Lazy-loading row data hooks through `UiConfig#load_children_path_builder` and `RenderState#lazy_loading`.
- Persisted state support through `TreeView::PersistedState`, `TreeView::StateStore`, and the install generator.
- Breadcrumb rendering helper for parent paths.
- Standard Ruby linting in development dependencies and CI.
- Rails version matrix Gemfiles and a main-push-only Rails compatibility CI job.

### Documentation

- Added Japanese documentation under `docs/`.
- Added language-specific documentation trees under `docs/ja/` and `docs/en/`.
- Added documentation language selector and i18n audit.
- Added installation, minimal usage, usage, API overview, and API reference documentation in Japanese and English.
- Added language-specific public API and release checklist docs.
- Added feature docs in Japanese and English for selection, lazy loading, windowed rendering, persisted state, breadcrumb, drag and drop, and children pagination.
- Added supporting docs in Japanese and English for glossary, node keys, tree diagnostics, cookbook, depth labels, row status, filtered trees, rendering boundaries, render scale, host app extension points, design policy, development, and code quality.
- Expanded the default TreeView static HTML mock to cover root, child, leaf, expanded, collapsed, hidden-count, selection, disabled selection, badge, marker, depth label, data attributes, and row actions examples.
- Added concrete multi-key sorter cookbook examples, including nil handling and stable fallback keys.
- Clarified beta documentation cleanup responsibilities and the split between static mockups in this repository and Rails playground behavior in the demo repository.
- Clarified the persisted state generator output and owner-side usage.
- Added children pagination guidance for lazy loading examples.
- Clarified large-tree performance hardening boundaries between TreeView gem support and host app responsibilities.
- Clarified public API, semi-public API, internal helper module, JavaScript entrypoint, and compatibility policy.
- Clarified that releases are normally managed by tags on `main`, with release branches reserved for parallel maintenance.
- Converted root compatibility docs into short language selectors where practical.
- Removed root-level docs compatibility selectors where language-specific docs already exist, keeping `docs/README.md`, `docs/i18n-audit.md`, language directories, and technical mockup assets as the primary docs structure.

### Tests

- Added coverage for the persisted state install generator outputs.
- Added unit and integration coverage for windowed rendering.
- Added JavaScript controller tests for state, selection, transfer, and remote-state behavior.

### Notes

- This gem intentionally focuses on TreeView rendering primitives.
- CRUD, authorization, business-specific actions, and selection side effects remain the responsibility of the host Rails application.
- `TreeView::VERSION` is already set to `0.1.0` for this release.
