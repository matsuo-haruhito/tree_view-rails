# TreeView mockups

This directory contains static HTML/CSS mockups for reviewing TreeView's baseline output without running a Rails app.

These files are intentionally small, reviewable assets in the gem repository. They show representative DOM structure, CSS hooks, ARIA attributes, and row states emitted by the reusable TreeView primitives.

They are **not** a complete Rails application and should not grow into host-app CRUD, query, authorization, seed data, or controller examples. Full playground/application examples belong in `matsuo-haruhito/tree_view-rails-demo` once that demo repository is public.

## Files

| File | Covers |
|---|---|
| [review-gallery.html](review-gallery.html) | Single-surface comparison hub for the current baseline and focused mockup references, with review-path jump links, embedded previews, and links to each full page. |
| [default-tree.html](default-tree.html) | Default table/tree output, checkbox selection, expanded/collapsed rows, badges, depth labels, row actions, and baseline CSS. |
| [resource-table-bridge.html](resource-table-bridge.html) | Resource table bridge reference showing shared hierarchy rows across fuller and narrower visible column sets without host-app table logic. |
| [narrow-sidebar-tree.html](narrow-sidebar-tree.html) | Narrow sidebar and small-width reference that keeps toggle controls, primary labels, and current or selection cues visible while secondary metadata wraps below. |
| [current-branch-sidebar.html](current-branch-sidebar.html) | Current branch sidebar reference showing current row, expanded ancestors, collapsed sibling branches, and depth/toggle cues without host-app navigation policy. |
| [row-status-depth-labels.html](row-status-depth-labels.html) | Focused comparison for row-wide status cues, selection checkbox disabled state, and depth labels without host-app authorization or business wording. |
| [interaction-states.html](interaction-states.html) | Lazy-loading, loading, error/retry, next-page, and drag/drop visual states. |
| [keyboard-focus-states.html](keyboard-focus-states.html) | Focused keyboard reference showing static focus-visible samples for toggle links, native controls, toolbar actions, and row actions without promising a full keyboard model. |
| [lazy-loading-handoff.html](lazy-loading-handoff.html) | Focused lazy-loading reference showing children container ownership, remote-state placeholder handoff, and error/retry slot boundaries. |
| [drop-positions.html](drop-positions.html) | Focused comparison for before, inside, and after drop-position cues plus the host-app-owned move policy boundary. |
| [persisted-state-boundary.html](persisted-state-boundary.html) | Focused persisted-state reference showing before, changed, restored, save-failed, and retry cues while keeping storage and retry policy host-app owned. |
| [turbo-frame-target.html](turbo-frame-target.html) | Focused Turbo Frame target boundary showing `data-turbo-frame` on TreeView toggle links beside the host-app-owned frame wrapper. |
| [drag-interactive-controls.html](drag-interactive-controls.html) | Focused comparison for native interactive controls, `data-tree-view-interactive`, and `data-tree-view-ignore-drag` inside draggable rows. |
| [interactive-marker-behaviors.html](interactive-marker-behaviors.html) | Focused comparison for `data-tree-view-interactive`, `data-tree-view-ignore-keyboard`, `data-tree-view-ignore-row-click`, and `data-tree-view-ignore-drag`, including the reserved host-app row-click boundary. |
| [windowed-rendering.html](windowed-rendering.html) | Focused comparison for `offset` / `limit` slices, current-row anchoring, and previous or next metadata without host-app pagination behavior. |
| [breadcrumb-paths.html](breadcrumb-paths.html) | Focused comparison for breadcrumb-path context beside the tree's own current-row cue, without modeling host-app routes or Turbo navigation. |
| [filtered-tree-modes.html](filtered-tree-modes.html) | Focused comparison for `filtered_tree_for` modes, showing matched-only, ancestor-retaining, and descendant-retaining output without host-app search behavior. |
| [path-tree-builder-rows.html](path-tree-builder-rows.html) | Focused PathTreeBuilder comparison for generated folder rows versus record-backed rows, keeping host-app columns/actions outside the gem contract. |
| [form-editing-rows.html](form-editing-rows.html) | Focused comparison for bulk-edit rows, per-row edit placement, and the boundary between TreeView selection checkboxes and host-app business controls. |
| [toolbar-actions.html](toolbar-actions.html) | Expand-all, collapse-all, and collapse-to-current-path toolbar reference showing enabled, disabled, and current-state variants without host-app routes or authorization copy. |
| [empty-state.html](empty-state.html) | No-root-items and no-results reference for the empty-row wrapper hook, full-width message slot, and host-app-owned copy. |
| [default-tree.css](default-tree.css) | Shared CSS for the static mockups. |

## Recommended review flow

1. Start with [review-gallery.html](review-gallery.html) when you want a quick side-by-side pass across the current mockup set, or use its review-path links to jump directly to a state family.
2. Open the linked full mockup page when one surface needs deeper inspection or longer notes.
3. Use [narrow-sidebar-tree.html](narrow-sidebar-tree.html) when review needs a focused pass on 22rem or 18rem frames where hierarchy cues stay visible while secondary metadata wraps below the primary label.
4. Use [current-branch-sidebar.html](current-branch-sidebar.html) when review needs to isolate `current_item:` / `current_key:` plus `auto_expand_ancestors: true` as a visual reference for the current row, ancestor path, and collapsed siblings.
5. Use [row-status-depth-labels.html](row-status-depth-labels.html) when review needs to compare row-wide readonly/disabled cues, selection checkbox disabled state, and depth-label meaning boundaries.
6. Use [resource-table-bridge.html](resource-table-bridge.html) when review needs a focused pass on table-owned columns plus TreeView-owned hierarchy cues.
7. Use [interaction-states.html](interaction-states.html) when review needs a focused pass on lazy loading, retry, pagination placeholders, or drag/drop states.
8. Use [keyboard-focus-states.html](keyboard-focus-states.html) when review needs to compare visible focus cues across toggle links, native controls, toolbar actions, and row actions without treating the mockup as a keyboard navigation contract.
9. Use [lazy-loading-handoff.html](lazy-loading-handoff.html) when review needs to isolate children container ownership and remote-state slot handoff from the broader interaction-state page.
10. Use [drop-positions.html](drop-positions.html) when review needs to compare before, inside, and after drop cues without modeling host-app reorder rules or persistence.
11. Use [persisted-state-boundary.html](persisted-state-boundary.html) when review needs to compare persisted expansion state before, changed, restored, save-failed, and retry cues without adding host-app persistence behavior.
12. Use [turbo-frame-target.html](turbo-frame-target.html) when review needs a focused pass on the configured `data-turbo-frame` link attribute and the host-app-owned frame target boundary.
13. Use [drag-interactive-controls.html](drag-interactive-controls.html) when review needs a focused pass on draggable rows that contain native controls, custom interactive markers, or drag-only ignore markers.
14. Use [interactive-marker-behaviors.html](interactive-marker-behaviors.html) when review needs to compare the broad interactive marker against the narrower keyboard, row-click, and drag behavior markers.
15. Use [windowed-rendering.html](windowed-rendering.html) when review needs to compare visible-row slicing and current-row anchoring without adding host-app paging controls.
16. Use [breadcrumb-paths.html](breadcrumb-paths.html) when review needs to compare breadcrumb-path context against the tree's own current-row cue without modeling host-app route design.
17. Use [filtered-tree-modes.html](filtered-tree-modes.html) when review needs to compare matched nodes against ancestor or descendant context without adding host-app search UI.
18. Use [path-tree-builder-rows.html](path-tree-builder-rows.html) when review needs to compare generated folder rows with record-backed rows without designing a file-manager application.
19. Use [form-editing-rows.html](form-editing-rows.html) when review needs to compare bulk edit rows, per-row edit action placement, or selection-versus-business checkbox roles without adding a real save workflow.
20. Use [empty-state.html](empty-state.html) when review needs a focused pass on no-root-items or no-results rows, the reusable empty-row wrapper hook, or the host-app-owned copy boundary.
21. Use [toolbar-actions.html](toolbar-actions.html) when review needs a focused pass on expand, collapse, or collapse-to-current-path affordances instead of row-by-row hierarchy layout.
22. Keep host-app wording, permissions, routes, and business actions out of this directory even when the gallery highlights a gap.

## Automated smoke coverage

- `npm run test:browser` opens representative mockup pages in Playwright and checks the review gallery, key local links, main headings, and sample regions.
- The smoke coverage is intentionally narrow. It catches broken HTML, blank pages, missing review links, and missing representative regions without adding screenshot baselines or visual diff review.

## Copy and language policy

- Mockups use short, product-neutral English copy so reviewers can compare layout and state cues without language changes becoming visual noise.
- Final labels, localization, permission messaging, and business wording remain host-app responsibilities.
- If a future mockup intentionally uses another language, document that exception here so reviewers know it is deliberate.

## Narrow-width guidance

- Keep the toggle control, the primary node label, and the current or selected cue visible in the first scan line.
- Move owner, status, badges, and less-frequent actions into stacked metadata or a compact action surface before hiding hierarchy cues.
- Treat exact truncation, action menus, and responsive breakpoints as host-app responsibilities. These mockups are reference layouts, not a shipped responsive design system.

## Current-branch guidance

- Use the current-branch sidebar mockup to review the visual result of expanding only the ancestors of the current item.
- Keep sibling branches collapsed unless the host app has a product reason to expose them by default.
- Treat route selection, sidebar ordering, permission-aware labels, and final navigation behavior as host-app responsibilities.

## Empty-state guidance

- Use `data-tree-view-empty-state="true"` together with `.tree-view-empty-row__content` and `.tree-view-empty-row__message` as the reusable baseline hook.
- Keep final empty copy, CTA, permission messaging, and filter-reset behavior in the host app.

## PathTreeBuilder guidance

- Keep generated folder rows visually distinct from record-backed rows, but avoid business-specific folder permission wording.
- Treat record columns, file actions, download affordances, and final file-manager behavior as host-app responsibilities.

## Drag/drop guidance

- Use focused static mockups to compare coarse visual cues such as dragging, valid target, blocked target, and drop position.
- Treat final move authorization, persistence, audit trails, and business copy as host-app responsibilities.

## Keyboard focus guidance

- Use `keyboard-focus-states.html` to review static focus-visible cues across representative focus targets.
- Keep tab order, shortcut keys, roving tabindex, and full treegrid keyboard behavior in the host app or a separate implementation issue.

## Review policy

- Prefer static HTML/CSS that can be inspected directly in pull-request diffs.
- Keep mockups product-neutral and free of host-app business behavior.
- Add screenshots only when visual regression review needs them; the source HTML/CSS should remain the canonical mockup.
- If a mockup needs Rails routes, controllers, database records, authorization, or Turbo responses to make sense, it belongs in a playground app rather than this directory.
