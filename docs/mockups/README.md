# TreeView mockups

This directory contains static HTML/CSS mockups for reviewing TreeView's baseline output without running a Rails app.

These files are intentionally small, reviewable assets in the gem repository. They show representative DOM structure, CSS hooks, ARIA attributes, and row states emitted by the reusable TreeView primitives.

They are **not** a complete Rails application and should not grow into host-app CRUD, query, authorization, seed data, or controller examples. Full playground/application examples belong in `matsuo-haruhito/tree_view-rails-demo` once that demo repository is public.

When a review starts from the gallery or a focused mockup page, confirm this static mockup / real demo app boundary before requesting new routes, persistence, CRUD flows, seeded records, or authorization examples in this directory.

## Files

| File | Covers |
|---|---|
| [review-gallery.html](review-gallery.html) | Single-surface comparison hub for the current baseline and focused mockup references, with review-path jump links, embedded previews, and links to each full page. |
| [default-tree.html](default-tree.html) | Default table/tree output, checkbox selection, expanded/collapsed rows, badges, depth labels, row actions, and baseline CSS. |
| [minimal-usage-first-render.html](minimal-usage-first-render.html) | Minimal usage first-render reference showing the small table/tree output from the controller, view, and row-partial docs without checkbox selection, badges, row actions, routes, CRUD, or seed data. |
| [readme-representative-visual-candidates.md](readme-representative-visual-candidates.md) | Candidate note for choosing a future README screenshot or GIF source before adding generated assets in #360. |
| [resource-table-bridge.html](resource-table-bridge.html) | Resource table bridge reference showing shared hierarchy rows across fuller and narrower visible column sets without host-app table logic. |
| [table-caption-context.html](table-caption-context.html) | Focused table caption and surrounding page structure reference showing host-app-owned heading, caption, summary, and actions around TreeView-owned row cues. |
| [narrow-sidebar-tree.html](narrow-sidebar-tree.html) | Narrow sidebar and small-width reference that keeps toggle controls, primary labels, and current or selection cues visible while secondary metadata wraps below. |
| [current-branch-sidebar.html](current-branch-sidebar.html) | Current branch sidebar reference showing current row, expanded ancestors, collapsed sibling branches, and depth/toggle cues without host-app navigation policy. |
| [row-status-depth-labels.html](row-status-depth-labels.html) | Focused comparison for row-wide status cues, selection checkbox disabled state, and depth labels without host-app authorization or business wording. |
| [toggle-icon-states.html](toggle-icon-states.html) | Focused comparison for expanded, collapsed, leaf, loading, and depth/type-based toggle icon states without choosing a host-app icon library. |
| [interaction-states.html](interaction-states.html) | Lazy-loading, loading, error/retry, next-page, and drag/drop visual states. |
| [children-pagination.html](children-pagination.html) | Focused comparison for next-page placeholder placement and branch-scoped load-more affordances without host-app cursor or Turbo behavior. |
| [reduced-motion-state-cues.html](reduced-motion-state-cues.html) | Focused low-motion reference for loading, retry, current/selected, and drop-target cues that remain readable without animation. |
| [keyboard-focus-states.html](keyboard-focus-states.html) | Focused keyboard reference showing static focus-visible samples for toggle links, native controls, toolbar actions, and row actions without promising a full keyboard model. |
| [keyboard-current-row/index.html](keyboard-current-row/index.html) | Focused keyboard reference comparing focus-visible cues, current-row styling, expansion state, and host-app-owned row actions in one tree. |
| [high-contrast-state-cues/index.html](high-contrast-state-cues/index.html) | Focused high-contrast reference for current, selected, focus-visible, error/retry, and drop-target cues that remain distinguishable beyond color alone. |
| [direction-aware-cues/index.html](direction-aware-cues/index.html) | Focused direction-aware reference comparing LTR baseline, RTL override, and vertical writing stress cases without promoting public styling hooks. |
| [lazy-loading-handoff.html](lazy-loading-handoff.html) | Focused lazy-loading reference showing children container ownership, remote-state placeholder handoff, and error/retry slot boundaries. |
| [drop-positions.html](drop-positions.html) | Focused comparison for before, inside, and after drop-position cues plus transfer disabled / invalid payload boundary states. |
| [persisted-state-boundary.html](persisted-state-boundary.html) | Focused persisted-state reference showing before, changed, restored, save-failed, retry, and cleanup retention review cues while keeping storage, retry policy, cleanup schedule, and retention policy host-app owned. |
| [turbo-frame-target.html](turbo-frame-target.html) | Focused Turbo Frame target boundary showing `data-turbo-frame` on TreeView toggle links beside the host-app-owned frame wrapper. |
| [drag-interactive-controls.html](drag-interactive-controls.html) | Focused comparison for native interactive controls, `data-tree-view-interactive`, and `data-tree-view-ignore-drag` inside draggable rows. |
| [interactive-marker-behaviors.html](interactive-marker-behaviors.html) | Focused comparison for `data-tree-view-interactive`, `data-tree-view-ignore-keyboard`, `data-tree-view-ignore-row-click`, and `data-tree-view-ignore-drag`, including the reserved host-app row-click boundary. |
| [windowed-rendering.html](windowed-rendering.html) | Focused comparison for `offset` / `limit` slices, current-row anchoring, and first / middle / last window metadata without host-app pagination behavior. |
| [breadcrumb-paths.html](breadcrumb-paths.html) | Focused comparison for breadcrumb-path context beside the tree's own current-row cue, without modeling host-app routes or Turbo navigation. |
| [filtered-tree-modes.html](filtered-tree-modes.html) | Focused comparison for `filtered_tree_for` modes, showing matched-only, ancestor-retaining, and descendant-retaining output without host-app search behavior. |
| [path-tree-builder-rows.html](path-tree-builder-rows.html) | Focused PathTreeBuilder comparison for generated folder rows versus record-backed rows, keeping host-app columns/actions outside the gem contract. |
| [node-presenter-row-partials.html](node-presenter-row-partials.html) | Focused NodePresenter row partial reference showing resolver-provided label, href, tooltip, badge, icon, and optional action beside host-app-owned columns and permissions. |
| [localized-row-labels.html](localized-row-labels.html) | Focused localized and long translated row label reference showing primary label, type badge, attribute label, secondary metadata, and tooltip cues without choosing final host-app translations. |
| [form-editing-rows.html](form-editing-rows.html) | Focused comparison for bulk-edit rows, per-row edit placement, and the boundary between TreeView selection checkboxes and host-app business controls. |
| [selection-max-count.html](selection-max-count.html) | Focused selection max-count reference showing below-limit, limit-reached, and limit-exceeded feedback while keeping final action copy host-app owned. |
| [selection-multi-tree-form.html](selection-multi-tree-form.html) | Focused multi-tree selection form reference showing source-specific selected counts, submit summary, empty state, and generated hidden input boundary as a review aid. |
| [children-pagination-selection-boundary.html](children-pagination-selection-boundary.html) | Focused children-pagination selection boundary reference showing loaded-row selection, unloaded descendants, rendered-only cascade/indeterminate cues, and host-app-owned bulk action semantics. |
| [toolbar-actions.html](toolbar-actions.html) | Expand-all, collapse-all, and collapse-to-current-path toolbar reference showing enabled, disabled fallback, missing-path fallback, current-state, metadata-boundary, and long/localized label variants without host-app routes or authorization copy. |
| [empty-state.html](empty-state.html) | No-root-items and no-results reference for the empty-row wrapper hook, full-width message slot, and host-app-owned copy. |
| [default-tree.css](default-tree.css) | Shared CSS for the static mockups. |

## Recommended review flow

1. Start with [review-gallery.html](review-gallery.html) when you want a quick side-by-side pass across the current mockup set, or use its review-path links to jump directly to a state family.
2. Before asking for a missing workflow in a mockup, confirm whether it belongs in the future real Rails demo app instead. Static mockups should not add CRUD, authorization, routes, seed data, controller behavior, or full host-app flows.
3. Open the linked full mockup page when one surface needs deeper inspection or longer notes.
4. Use [minimal-usage-first-render.html](minimal-usage-first-render.html) when review needs to inspect the first visible output from the minimal usage docs before richer baseline states.
5. Use [narrow-sidebar-tree.html](narrow-sidebar-tree.html) when review needs a focused pass on 22rem or 18rem frames where hierarchy cues stay visible while secondary metadata wraps below the primary label.
6. Use [current-branch-sidebar.html](current-branch-sidebar.html) when review needs to isolate `current_item:` / `current_key:` plus `auto_expand_ancestors: true` as a visual reference for the current row, ancestor path, and collapsed siblings.
7. Use [row-status-depth-labels.html](row-status-depth-labels.html) when review needs to compare row-wide readonly/disabled cues, selection checkbox disabled state, and depth-label meaning boundaries.
8. Use [toggle-icon-states.html](toggle-icon-states.html) when review needs to compare `toggle_icons:` expanded, collapsed, leaf, loading, and depth/type variation without selecting a final icon library.
9. Use [resource-table-bridge.html](resource-table-bridge.html) when review needs a focused pass on table-owned columns plus TreeView-owned hierarchy cues.
10. Use [interaction-states.html](interaction-states.html) when review needs a focused pass on lazy loading, retry, pagination placeholders, or drag/drop states.
11. Use [children-pagination.html](children-pagination.html) when review needs a narrower pass on where next-page placeholder rows and load-more affordances sit inside one expanded branch.
12. Use [reduced-motion-state-cues.html](reduced-motion-state-cues.html) when review needs to compare loading, retry, current/selected, and drop-target cues that remain readable without animation.
13. Use [keyboard-focus-states.html](keyboard-focus-states.html) when review needs to compare visible focus cues across toggle links, native controls, toolbar actions, and row actions without treating the mockup as a keyboard navigation contract.
14. Use [keyboard-current-row/index.html](keyboard-current-row/index.html) when review needs to compare focus-visible cues beside `aria-current="page"`, expanded/collapsed rows, and host-app-owned row actions in the same tree.
15. Use [high contrast state cues](high-contrast-state-cues/index.html) when review needs to compare current, selected, focus-visible, error/retry, and drop-target cues without relying on color alone.
16. Use [direction-aware cues](direction-aware-cues/index.html) when review needs to compare LTR baseline, RTL host-app override, and vertical writing stress cases without treating directional styling as a public hook contract.
17. Use [lazy-loading-handoff.html](lazy-loading-handoff.html) when review needs to isolate children container ownership and remote-state slot handoff from the broader interaction-state page.
18. Use [drop-positions.html](drop-positions.html) when review needs to compare before, inside, after, transfer disabled, and invalid transfer boundary cues without modeling host-app reorder rules or persistence.
19. Use [persisted-state-boundary.html](persisted-state-boundary.html) when review needs to compare persisted expansion state before, changed, restored, save-failed, retry, and cleanup retention cues without adding host-app persistence behavior, cleanup jobs, or retention policy.
20. Use [turbo-frame-target.html](turbo-frame-target.html) when review needs a focused pass on the configured `data-turbo-frame` link attribute and the host-app-owned frame target boundary.
21. Use [drag-interactive-controls.html](drag-interactive-controls.html) when review needs a focused pass on draggable rows that contain native controls, custom interactive markers, or drag-only ignore markers.
22. Use [interactive-marker-behaviors.html](interactive-marker-behaviors.html) when review needs to compare the broad interactive marker against the narrower keyboard, row-click, and drag behavior markers.
23. Use [windowed-rendering.html](windowed-rendering.html) when review needs to compare visible-row slicing, current-row anchoring, and first / last window boundary metadata without adding host-app paging controls.
24. Use [breadcrumb-paths.html](breadcrumb-paths.html) when review needs to compare breadcrumb-path context against the tree's own current-row cue without modeling host-app route design.
25. Use [filtered-tree-modes.html](filtered-tree-modes.html) when review needs to compare matched nodes against ancestor or descendant context without adding host-app search UI.
26. Use [path-tree-builder-rows.html](path-tree-builder-rows.html) when review needs to compare generated folder rows with record-backed rows without designing a file-manager application.
27. Use [node-presenter-row-partials.html](node-presenter-row-partials.html) when review needs to compare NodePresenter-provided row partial values against host-app-owned columns, permissions, and final actions.
28. Use [localized-row-labels.html](localized-row-labels.html) when review needs to compare long localized row labels, type badges, attribute labels, secondary metadata, and tooltip cues without deciding final host-app translations.
29. Use [form-editing-rows.html](form-editing-rows.html) when review needs to compare bulk edit rows, per-row edit action placement, or selection-versus-business checkbox roles without adding a real save workflow.
30. Use [selection-max-count.html](selection-max-count.html) when review needs to compare below-limit, limit-reached, and limit-exceeded selection feedback without adding runtime behavior or final bulk-action copy.
31. Use [selection-multi-tree-form.html](selection-multi-tree-form.html) when review needs to compare multiple TreeView selection groups in one form, source-specific counts, and generated hidden input sync boundaries. Treat its hidden input rows as a review aid; [Selection](../en/selection.md#hidden-input-sync-for-regular-form-submit) is the contract for per-payload hidden input sync.
32. Use [children-pagination-selection-boundary.html](children-pagination-selection-boundary.html) when selection review intersects with children pagination, rendered-only cascade/indeterminate cues, or unloaded descendant boundaries.
33. Use [table-caption-context.html](table-caption-context.html) when review needs to compare host-app-owned heading, caption, summary, and adjacent actions around TreeView-owned row hierarchy cues.
34. Use [empty-state.html](empty-state.html) when review needs a focused pass on no-root-items or no-results rows, the reusable empty-row wrapper hook, or the host-app-owned copy boundary.
35. Use [toolbar-actions.html](toolbar-actions.html) when review needs a focused pass on expand, collapse, collapse-to-current-path, disabled fallback, missing-path fallback, current-state cues, or long/localized label wrapping affordances instead of row-by-row hierarchy layout.
36. Keep host-app wording, permissions, routes, and business actions out of this directory even when the gallery highlights a gap.

## Demo boundary guidance

- Use these mockups to review static DOM structure, CSS hooks, ARIA attributes, row states, and product-neutral responsibility boundaries.
- Use the future real Rails demo app for end-to-end flows that need routes, controller behavior, persistence, authorization, seeded records, CRUD screens, or business workflow copy.
- Do not add direct public demo links from the mockups until the demo repository is public and its publication checklist is ready.

## Automated smoke coverage

- `npm run test:browser` opens every HTML mockup listed in the Files table and checks the review gallery, local links, main headings, back-to-gallery links, representative sample regions, and the existing lazy-loading viewport overflow smoke.
- The smoke coverage is intentionally narrow. It catches broken HTML, blank pages, missing review links, and missing representative regions without adding screenshot baselines or visual diff review.

## Copy and language policy

- Mockups use short, product-neutral English copy so reviewers can compare layout and state cues without language changes becoming visual noise.
- `toolbar-actions.html` intentionally includes a narrow long/localized label stress case so reviewers can inspect wrapping, metadata fallback, disabled state, and current-state cues without choosing final translations.
- `localized-row-labels.html` intentionally uses long localized-style English labels to stress row wrapping, badge placement, attribute labels, secondary metadata, and tooltip cues without choosing final translations.
- Final labels, localization, permission messaging, and business wording remain host-app responsibilities.
- If a future mockup intentionally uses another language, document that exception here so reviewers know it is deliberate.

Record deliberate copy or language exceptions in this list. Add a row when a mockup needs non-neutral copy, localized-style text, or another language for a review purpose; do not use this list to choose final host-app copy.

| Mockup | Deliberate exception | Review reason |
|---|---|---|
| `toolbar-actions.html` | Long / localized-style toolbar labels | Stress wrapping, metadata fallback, disabled state, and current-state cues without choosing final translations. |
| `localized-row-labels.html` | Long localized-style row labels and metadata | Stress primary label wrapping, badge placement, attribute labels, secondary metadata, and tooltip cues without choosing final translations. |

## Selection form guidance

- Use selection form mockups to compare visible counts, source separation, and generated hidden input boundaries at review time.
- Use [children-pagination-selection-boundary.html](children-pagination-selection-boundary.html) when selection review intersects with children pagination, rendered-only cascade/indeterminate cues, or unloaded descendant boundaries.
- Treat [Selection](../en/selection.md#hidden-input-sync-for-regular-form-submit) as the source of truth for hidden input sync: TreeView mirrors one JSON payload per hidden input, and host apps own final params grouping, submit summaries, and business action copy.
- Treat [Children pagination](../en/children-pagination.md#selection-and-dragdrop-interactions) as the source of truth when a bulk action should include unloaded descendants: host apps need a query-backed or server-side intent rather than relying on DOM-submitted loaded rows.

## Children pagination guidance

- Use `children-pagination.html` to review next-page placeholder placement and branch-scoped load-more affordances without turning the mockup into a cursor, Turbo Stream, or authorization contract.
- Keep cursor encoding, page limits, retry behavior, and final button copy in the host app.
- Use `children-pagination-selection-boundary.html` when the review question includes selection state across loaded rows and unloaded descendants.

## Narrow-width guidance

- Keep the toggle control, the primary node label, and the current or selected cue visible in the first scan line.
- Move owner, status, badges, and less-frequent actions into stacked metadata or a compact action surface before hiding hierarchy cues.
- Treat exact truncation, action menus, and responsive breakpoints as host-app responsibilities. These mockups are reference layouts, not a shipped responsive design system.

## Current-branch guidance

- Use the current-branch sidebar mockup to review the visual result of expanding only the ancestors of the current item.
- Keep sibling branches collapsed unless the host app has a product reason to expose them by default.
- Treat route selection, sidebar ordering, permission-aware labels, and final navigation behavior as host-app responsibilities.

## Direction-aware guidance

- Use the direction-aware cues mockup to compare the baseline current-row / hierarchy cues with RTL and vertical writing stress samples.
- Keep final RTL policy, locale-specific spacing, design-system colors, and any public styling hook promotion in the host app or a separate product decision.

## Empty-state guidance

- Use `data-tree-view-empty-state="true"` together with `.tree-view-empty-row__content` and `.tree-view-empty-row__message` as the reusable baseline hook.
- Keep final empty copy, CTA, permission messaging, and filter-reset behavior in the host app.

## PathTreeBuilder guidance

- Keep generated folder rows visually distinct from record-backed rows, but avoid business-specific folder permission wording.
- Treat record columns, file actions, download affordances, and final file-manager behavior as host-app responsibilities.

## Toolbar guidance

- Use `toolbar-actions.html` to review visual action availability, current-path emphasis, disabled fallback, and missing-path fallback without treating the page as a public API manifest for `tree_view_toolbar_action_metadata`.
- Keep route builders, authorization policy, final localized labels, and permission messages in the host app.
- Use #1449 for helper return-shape / manifest-backed public contract decisions instead of expanding this mockup into API documentation.

## Drag/drop guidance

- Use focused static mockups to compare coarse visual cues such as dragging, valid target, blocked target, drop position, and invalid transfer boundaries.
- Treat final move authorization, persistence, audit trails, and business copy as host-app responsibilities.

## Motion guidance

- Use `reduced-motion-state-cues.html` when the review question is whether loading, retry, current/selected, or drop-target states remain understandable without animation.
- Keep animation policy, visual regression baselines, and runtime event behavior in separate implementation or quality issues.

## Keyboard focus guidance

- Use `keyboard-focus-states.html` to review static focus-visible cues across representative focus targets.
- Use `keyboard-current-row/index.html` when the review needs to compare focus, current-row, expansion, and row-action cues together.
- Use the [high contrast state cues](high-contrast-state-cues/index.html) focused subpage when the review question is whether state cues remain distinguishable without relying on color alone.
- Keep tab order, shortcut keys, roving tabindex, and full treegrid keyboard behavior in the host app or a separate implementation issue.

## Review policy

- Prefer static HTML/CSS that can be inspected directly in pull-request diffs.
- Keep mockups product-neutral and free of host-app business behavior.
- Add screenshots only when visual regression review needs them; the source HTML/CSS should remain the canonical mockup.
- If a mockup needs Rails routes, controllers, database records, authorization, or Turbo responses to make sense, it belongs in a playground app rather than this directory.
