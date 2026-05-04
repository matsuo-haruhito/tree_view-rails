# Changelog

This changelog uses the following categories when applicable:

- `Added` for new features.
- `Changed` for changes in existing behavior.
- `Fixed` for bug fixes.
- `Deprecated` for features planned for removal.
- `Removed` for removed features.
- `Documentation` for docs-only changes.

Breaking changes and required migration notes should be called out explicitly in the relevant version section.

## 0.1.0 - Initial release

### Added

- Core tree rendering primitives for Rails applications.
- `TreeView::Tree` for parent-child records.
- `TreeView::GraphAdapter` for graph-like or heterogeneous node structures.
- `TreeView::PathTree` via `Tree#path_tree_for(items)` for rendering matched items with completed parent paths.
- `TreeView::ReverseTree` via `Tree#reverse_tree_for(items)` for rendering child-to-parent paths.
- `TreeView::RenderState` for screen-level rendering options.
- `tree_view_rows(render_state)` helper.
- Host app row partial support via `row_partial`.
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
- Japanese documentation under `docs/`.

### Documentation

- Public API and compatibility policy are documented in `docs/public-api.md`.
- Release, versioning, CHANGELOG, and gem packaging checks are documented in `docs/release.md`.
- Asset and importmap packaging expectations are documented in `docs/installation.md`.
- JavaScript controller responsibility boundaries are documented in `docs/design-policy.md`.
- TreeView-specific concepts and API names are defined in `docs/glossary.md`.

### Notes

- This gem intentionally focuses on TreeView rendering primitives.
- CRUD, authorization, business-specific actions, and selection side effects remain the responsibility of the host Rails application.
