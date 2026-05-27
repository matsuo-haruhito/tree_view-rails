# TreeView mockups

This directory contains static HTML/CSS mockups for reviewing TreeView's baseline output without running a Rails app.

These files are intentionally small, reviewable assets in the gem repository. They show representative DOM structure, CSS hooks, ARIA attributes, and row states emitted by the reusable TreeView primitives.

They are **not** a complete Rails application and should not grow into host-app CRUD, query, authorization, seed data, or controller examples. Full playground/application examples belong in `matsuo-haruhito/tree_view-rails-demo` once that demo repository is public.

## Files

| File | Covers |
|---|---|
| [review-gallery.html](review-gallery.html) | Single-surface comparison hub for the current baseline and focused mockup references, with embedded previews and links to each full page. |
| [default-tree.html](default-tree.html) | Default table/tree output, checkbox selection, expanded/collapsed rows, badges, depth labels, row actions, and baseline CSS. |
| [resource-table-bridge.html](resource-table-bridge.html) | Resource table bridge reference showing shared hierarchy rows across fuller and narrower visible column sets without host-app table logic. |
| [narrow-sidebar-tree.html](narrow-sidebar-tree.html) | Narrow sidebar and small-width reference that keeps toggle controls, primary labels, and current or selection cues visible while secondary metadata wraps below. |
| [interaction-states.html](interaction-states.html) | Lazy-loading, loading, error/retry, next-page, and drag/drop visual states. |
| [windowed-rendering.html](windowed-rendering.html) | Focused comparison for `offset` / `limit` slices, current-row anchoring, and previous or next metadata without host-app pagination behavior. |
| [filtered-tree-modes.html](filtered-tree-modes.html) | Focused comparison for `filtered_tree_for` modes, showing matched-only, ancestor-retaining, and descendant-retaining output without host-app search behavior. |
| [toolbar-actions.html](toolbar-actions.html) | Expand-all / collapse-all toolbar reference showing enabled, disabled, and current-state variants without host-app routes or authorization copy. |
| [empty-state.html](empty-state.html) | No-root-items and no-results reference for the empty-row wrapper hook, full-width message slot, and host-app-owned copy. |
| [default-tree.css](default-tree.css) | Shared CSS for the static mockups. |

## Recommended review flow

1. Start with [review-gallery.html](review-gallery.html) when you want a quick side-by-side pass across the current mockup set.
2. Open the linked full mockup page when one surface needs deeper inspection or longer notes.
3. Use [resource-table-bridge.html](resource-table-bridge.html) when review needs a focused pass on table-owned columns plus TreeView-owned hierarchy cues.
4. Use [interaction-states.html](interaction-states.html) when review needs a focused pass on lazy loading, retry, pagination placeholders, or drag/drop states.
5. Use [windowed-rendering.html](windowed-rendering.html) when review needs to compare visible-row slicing and current-row anchoring without adding host-app paging controls.
6. Use [filtered-tree-modes.html](filtered-tree-modes.html) when review needs to compare matched nodes against ancestor or descendant context without adding host-app search UI.
7. Use [toolbar-actions.html](toolbar-actions.html) when review needs a focused pass on tree-wide expand / collapse affordances instead of row-by-row hierarchy layout.
8. Keep host-app wording, permissions, routes, and business actions out of this directory even when the gallery highlights a gap.

## Copy and language policy

- Mockups use short, product-neutral English copy so reviewers can compare layout and state cues without language changes becoming visual noise.
- Final labels, localization, permission messaging, and business wording remain host-app responsibilities.
- If a future mockup intentionally uses another language, document that exception here so reviewers know it is deliberate.

## Narrow-width guidance

- Keep the toggle control, the primary node label, and the current or selected cue visible in the first scan line.
- Move owner, status, badges, and less-frequent actions into stacked metadata or a compact action surface before hiding hierarchy cues.
- Treat exact truncation, action menus, and responsive breakpoints as host-app responsibilities. These mockups are reference layouts, not a shipped responsive design system.

## Empty-state guidance

- Use `data-tree-view-empty-state="true"` together with `.tree-view-empty-row__content` and `.tree-view-empty-row__message` as the reusable baseline hook.
- Keep final empty copy, CTA, permission messaging, and filter-reset behavior in the host app.

## Review policy

- Prefer static HTML/CSS that can be inspected directly in pull-request diffs.
- Keep mockups product-neutral and free of host-app business behavior.
- Add screenshots only when visual regression review needs them; the source HTML/CSS should remain the canonical mockup.
- If a mockup needs Rails routes, controllers, database records, authorization, or Turbo responses to make sense, it belongs in a playground app rather than this directory.