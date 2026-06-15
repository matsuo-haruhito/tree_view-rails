# Changelog

This changelog uses the following categories when applicable:

- `Added` for new features.
- `Changed` for changes in existing behavior.
- `Fixed` for bug fixes.
- `Deprecated` for features planned for removal.
- `Removed` for removed features.
- `Documentation` for docs-only changes.
- `Tests` for test, CI, and package verification changes.

Breaking changes and required migration notes should be called out explicitly in the relevant version section.

## Unreleased

Release preparation notes:

- Treat `Added`, `Changed`, and `Fixed` entries as the primary reader-facing release notes. Many entries in this section expand public configuration, helper, JavaScript, or manifest-backed surfaces and should stay visible to host-app maintainers.
- Keep `Documentation` and `Tests` entries available as release evidence, but summarize or group them during the release preparation PR when they are maintenance-only and do not change runtime behavior.
- Record public API manifest, package-root export, and documented hook changes by their user-visible effect. Use `Documentation` only when docs or manifest guidance changed without a runtime or compatibility-surface change.
- No breaking change, deprecation, or removal is currently called out in `Unreleased`. If a later release review identifies one, add the migration note before moving these entries into a dated version section.

### Added

- Added localized display-name helpers for model, attribute, and node type names through ActiveModel / I18n.
- Added `UiConfig#turbo_frame` and `UiConfigBuilder#build_turbo(turbo_frame:)` so Turbo toggle links can target a host-app Turbo Frame without custom JavaScript.
- Added `tree_view_toolbar(render_state)` for rendering tree-wide expand/collapse toolbar actions through `UiConfig#toggle_all_path`.
- Added `TreeView::NodePresenter` as a thin adapter for node-level resolver hooks and `RenderState` row class/data/icon/badge builders.
- Added owner model argument support to the persisted state install generator so `tree_view:state:install User` can include `TreeViewStateOwner` in an existing owner model.
- Added `TreeView::StateStore#clear!` so host apps can clear saved expansion state for an owner and tree instance key.
- Added `RenderState` current node ancestor expansion via `current_item` / `current_key` and `auto_expand_ancestors`.
- Added `TreeView::PathTreeBuilder` for building generated folder nodes and record nodes from path-like record values.
- Added `TreeView.configuration.render_log_level`, defaulting to `:warn`, so TreeView helper-rendered partial logs can be silenced without changing the host app's global Rails logger level.
- Added a public TreeView-specific error hierarchy rooted at `TreeView::Error` for rescuing validation and configuration failures.
- Added explicit `UiConfig#mode` values for `:turbo`, `:static`, and `:client`, plus `UiConfigBuilder#build_turbo` and `UiConfigBuilder#build_client_side`.
- Added client-side-only expand/collapse mode that renders collapsed descendants into initial HTML and toggles rows in the browser with the bundled `tree-view-client` controller.
- Added `TreeView::Diagnostics.run` as a consolidated diagnostics entrypoint for node keys, DOM IDs, orphans, and cycles.
- Added `tree_children_container_dom_id`, `tree_remote_state_placeholder_dom_id`, and `tree_remote_state_placeholder_attributes` so host apps can reuse stable lazy-loading placeholder IDs and data attributes.
- Added `TreeViewEventDetailKeys` as a package-root JavaScript export for host app tests that need machine-readable documented event detail key names.
- Added `toggle_icons` to the manifest-backed grouped option compatibility surface while keeping the existing RenderState option behavior unchanged.

### Changed

- Removed misleading `aria-controls` from Turbo toggle links until TreeView has a single stable controlled target.
- Clarified public builder naming decisions: prefer `badge_builder`, keep `icon_builder` as a compatibility alias, treat `row_event_payload_builder` as transfer-specific, and document `loading_builder` / `error_builder` as boolean predicates.
- Strengthened pull request CI to run Ruby specs alongside Standard Ruby lint while keeping broader compatibility and release checks on `main`.
- Split RenderState selection and lazy-loading normalization into internal configuration objects while keeping the public RenderState API compatible.
- Remote-state retry actions now mark the row `loading` and dispatch `tree-view-remote-state:change` before the existing retry event, so host app listeners can observe the loading transition consistently.

### Fixed

- Cleaned up generated selection hidden inputs when selection controllers disconnect, scoped to each controller source id.

### Documentation

- Added localized names docs in Japanese and English.
- Added Turbo Frame option docs in Japanese and English.
- Added NodePresenter row partial cookbook docs and clarified criteria for promoting app-specific UI patterns into TreeView.
- Added toolbar helper docs in Japanese and English.
- Added README adoption guidance to help users decide whether TreeView fits their use case and to clarify the virtual scrolling boundary.
- Promoted accessibility semantics as a first-class capability in the README and docs indexes, including ARIA placement, keyboard boundaries, and host-app responsibilities.
- Added accessibility semantics docs for table-first TreeView rows and ARIA placement policy.
- Added client-side toggle mode docs in Japanese and English, including static / Turbo / client-side mode comparison and CSS customization guidance using `aria-expanded`.
- Added error hierarchy docs in Japanese and English, including public rescue guidance and `ArgumentError` compatibility notes.
- Added form and editing row docs for bulk edit forms, inline-editing layouts, Form Objects, validation errors, row actions, and host-app responsibility boundaries.
- Added public name decision docs in Japanese and English.
- Added render log level docs in Japanese and English.
- Added JavaScript event contract docs in Japanese and English for public Stimulus events and payload details.
- Clarified JavaScript event contract docs that `TreeViewEventDetailKeys` mirrors documented detail key names for machine-readable test assertions without changing event payload shape.
- Clarified release checklist guidance for documented JavaScript wiring surfaces, including `data-tree-view-*` integration hooks and selection controller host-element value attributes, alongside machine-readable package-root exports.
- Added migration guides in Japanese and English to summarize compatibility promises, deprecations, rename handling, and release-note expectations.
- Clarified the CI policy split between pull request Ruby checks and broader `main` / release checks.
- Clarified development docs for the Ruby-backed `npm run test:entrypoints` manifest loader path and setup expectations.
- Clarified development docs that `.nvmrc`, `package.json` `engines.node`, and workflow `node-version` stay aligned by a Node version source drift guard.
- Clarified Development docs for the Ruby version source and CI changed-file policy guard commands, including Bundler dependency package-sensitive guidance.
- Clarified that RenderState current-branch examples should prefer `current_item` / `current_key` with `auto_expand_ancestors` when only the current path should start open.
- Clarified that RenderWindow and windowed rendering limit HTML output only, while Lazy Loading, Children Pagination, and host-app virtual scrolling handle data-loading and DOM-virtualization concerns.
- Updated lazy-loading docs in Japanese and English to use helper-based children and remote-state placeholder examples.
- Added `TreeView::Diagnostics.run` documentation in Japanese and English for aggregate pre-render validation results.
- Added FAQ guidance for keyboard behavior and `treegrid` responsibility boundaries in Japanese and English.
- Added a host-app extension hook reverse lookup table in Japanese and English.
- Added toolbar disabled-action troubleshooting guidance in Japanese and English.
- Added GraphAdapter troubleshooting guidance in Japanese and English for resolver shape, heterogeneous node keys, and diagnostics handoff.
- Clarified the LocalizedNames public API boundary in Japanese and English so helper fallback behavior stays separate from host-app row rendering.
- Added ResourceTableRenderState API reference entries in Japanese and English for the bridge call signature, row partial fallback, and table-layer responsibility boundary.
- Added glossary entries in Japanese and English for integration-surface terms such as remote state, transfer payloads, drop position, resource-table bridge, windowed rendering, and children pagination.
- Added Standard Ruby preflight guidance to the development docs for connector or GitHub API edits to Ruby files.
- Documented the bilingual page-set parity policy for `docs/en` and `docs/ja`, including technical-asset and temporary single-language exceptions.
- Added downstream host app smoke / release evidence guidance in Japanese and English, separating upstream TreeView release evidence from host-app adoption notes.
- Clarified the remote-state retry event ordering in the JavaScript event contract docs in Japanese and English.
- Added direction-aware styling boundary entry points to the root docs index.
- Added a direction-aware hierarchy cue static mockup for LTR / RTL review of branch lines, toggle placement, current-row cues, selected rows, and row actions.
- Added transfer disabled / invalid boundary states to the drop-position mockup and updated the mockup review guidance.
- Added static mockup references for multi-tree selection forms, toggle icon states, high-contrast state cues, reduced-motion state cues, and localized row labels.
- Added focused mockup references for RenderWindow boundary metadata and direction-aware visual cue boundaries.
- Added a status-heavy row composition mockup section for dense business columns, row status cues, and host-app-owned action availability.
- Added a current-branch sidebar breadcrumb mockup for reviewing route context and row-local hierarchy cues in narrow panes.
- Added direction-aware styling boundary docs for host-app-owned RTL, writing direction, current-row cues, hierarchy connectors, and toggle spacing overrides.
- Added Decision guide guidance for choosing Static, Turbo, or Client-side toggle mode before tuning render depth or loading strategy.
- Clarified docs index entry points for PathTreeBuilder, Children Pagination, and large-tree reading paths.
- Added docs index entry points for Accessibility Semantics so ARIA placement, keyboard boundaries, and automated check allowances are easier to find before review.
- Corrected Windowed Rendering docs examples and metadata tables to use the implemented `TreeView::RenderWindow#previous?` / `#next?` API names.
- Clarified mockup copy and language policy exception recording for deliberate review stress cases.
- Clarified that `docs/mockups/README.md` is the source of truth for mockup technical asset inventory.
- Added root docs index entry points for the English and Japanese Rendering Boundaries guides.
- Added malformed selection params troubleshooting guidance in English and Japanese, including `TreeView.parse_selection_params` error boundaries and host-app-owned request policy.

### Tests

- Added localized names specs and public API compatibility coverage.
- Added Turbo Frame option unit and integration specs.
- Added toolbar helper specs.
- Added toolbar action/state manifest and docs drift guard coverage.
- Added `NodePresenter` specs and `RenderState` integration specs.
- Added generator specs for persisted state owner concern injection.
- Added RenderState specs for current node ancestor auto-expansion.
- Added accessibility semantics integration specs for row ARIA state in static, collapsed, selection, and windowed rendering.
- Added render traversal regression specs for deep trees, wide trees, collapsed render scope, filtered path trees, sorter call growth, children lookup scope, and max leaf distance behavior.
- Added specs for TreeView-specific error rescue behavior.
- Added Ruby and JavaScript specs for client-side toggle mode, mode builders, public API exports, and browser-local descendant visibility updates.
- Added specs for RenderState internal configuration objects and the consolidated diagnostics entrypoint.
- Added JavaScript public event contract specs for selection, remote state, and transfer events.
- Added package-root frozen object contract coverage for public JavaScript object exports.
- Added `TreeViewEventDetailKeys` manifest/export guard coverage in entrypoint smoke and focused Ruby specs.
- Added entrypoint smoke coverage that rejects package-root exports missing from `config/public_api_manifest.yml`.
- Added Node version source drift guard coverage for `.nvmrc`, `package.json` `engines.node`, workflow `node-version`, and development docs.
- Improved entrypoint smoke diagnostics for Ruby manifest loader and JSON parse failures without changing public export assertions.
- Added transfer controller regression guards for drop position calculation and invalid payload event dispatch.
- Added selection controller disconnect cleanup specs for generated hidden input lifecycle.
- Added remote-state retry event contract coverage for the loading `change` event dispatched before retry.
- Added browser smoke coverage for the direction-aware hierarchy cue mockup across desktop and narrow viewports.
- Added browser smoke coverage for representative docs mockup pages and the review gallery.
- Added docs entrypoint guard coverage for keeping README feature links and docs index targets aligned.
- Added README orientation asset smoke coverage for the root README image, default-tree baseline mockup, and focused mockup review links.
- Expanded package verification coverage for TreeViewHelper subfiles, the breadcrumb helper, representative Japanese toolbar locale, and Japanese release docs files.
- Added docs smoke coverage for troubleshooting diagnostics reader journeys, toolbar contract source docs, public API hook signals, mockup review flow / gallery alignment, and docs entrypoint group selection.
- Added CI changed-file policy guard coverage for workflow output key drift, docs entrypoint routing, and JavaScript npm command references.
- Added package-sensitive CI guard coverage for `Gemfile` and `Gemfile.lock` changes so Ruby dependency updates reach gem package verification.
- Added maintenance guard coverage for Ruby version source drift, grouped package contents verification, and Public API manifest event classification.
- Added docs smoke and package verification coverage for grouped RenderState option docs signals, Public Setup Surface reader journeys, and README-linked public JavaScript / setup docs packaging.
- Added setup generator optional-argument manifest guard coverage and release-note candidate docs package verification.
- Added CI changed-file detection workflow signal and configuration docs signal coverage for base-ref diff routing and `TreeView.configure` option docs.
- Added controller entries contract smoke and `tree_view_rows` / Windowed Rendering docs signal coverage to the docs entrypoint suite.

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
