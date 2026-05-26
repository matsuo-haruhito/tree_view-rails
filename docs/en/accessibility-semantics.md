# Accessibility semantics

This page records TreeView's current accessibility policy for table-based tree rows and describes the behavior host apps can rely on today.

## Goal

TreeView treats accessibility as a first-class integration concern. The gem provides consistent row-level ARIA state for tree-like table rows while host apps keep ownership of page structure, domain labels, captions, forms, and business-specific interactions.

## Policy

TreeView is table-first with tree-like row controls.

TreeView renders host-app business columns in table rows, so it does not claim full `tree` semantics and does not currently opt into full `treegrid` semantics. Host apps should treat the generated markup as a table that includes expansion controls, selection state, current-row state, and optional lazy-loading state.

Any move toward `treegrid` semantics should be a focused compatibility decision. It should not happen as an incidental attribute change.

## Current ARIA placement

- `aria-level` lives on the rendered row and describes the node depth.
- `aria-expanded` lives on branch rows and on Turbo toggle links where the link performs an expand/collapse action.
- `aria-selected` lives on the rendered row and mirrors TreeView row selection state.
- `aria-current="page"` lives on the rendered row when the row represents the current item.
- `aria-controls` is intentionally not emitted by toggle links for now.
- TreeView intentionally does not emit `role="tree"` or `role="treeitem"` for table rows today.

## Intentional allowances for automated accessibility checks

When automated checks expect full `tree` or `treegrid` semantics, use this section as the current policy baseline.

- TreeView rows intentionally keep table semantics with row-level ARIA state instead of adding `role="tree"`, `role="treegrid"`, or `role="treeitem"`.
- Toggle links may expose `aria-expanded` without `aria-controls` because there is no single stable controlled target across static, Turbo, and lazy-loading flows.
- TreeView does not promise a full treegrid keyboard model today; page-level focus order, captions, and shortcut behavior remain host-app responsibilities.
- `aria-selected` reflects TreeView row selection state only. It should not be interpreted as host-app business checkbox semantics unless the host app intentionally maps those concepts together.

If a future browser-level accessibility smoke test treats one of these patterns as an allowed exception, the test comment or suppression note should cite this section and name the specific policy it relies on.

## Empty-state and hidden-count hooks

- Empty rows now wrap the message in `.tree-view-empty-row__content` and `.tree-view-empty-row__message`, with `data-tree-view-empty-state="true"` on the wrapper so host apps can style or target empty states without overriding the partial.
- Static hidden-count text appends a screen-reader-only suffix from `tree_view.accessibility.hidden_descendants`, which defaults to ` descendants` and can be localized by the host app.

## Supported rendering examples

### Static table rows

Static rendering emits table rows with row-level depth and branch state:

```html
<tr id="project_1" aria-level="1" aria-expanded="true" aria-selected="false">
  ...
</tr>
```

When a branch is collapsed by `initial_state`, `collapsed_keys`, or `max_initial_depth`, the branch row exposes `aria-expanded="false"` and descendants that are not part of the current render are omitted from the HTML.

### Turbo trees

Turbo rendering uses the same row-level ARIA state as static rendering. Toggle links that perform expand/collapse actions also expose the current `aria-expanded` value so assistive technology can announce the control state.

TreeView does not add `aria-controls` to Turbo toggle links because a toggle may affect multiple descendant rows and lazy-loading targets may not exist in the DOM yet.

### Checkbox trees

When selection is enabled, `aria-selected` on each rendered row mirrors TreeView's selected row state. Checkbox payloads and disabled state are still controlled by the selection APIs documented in [Selection](selection.md).

## Keyboard behavior

TreeView registers Stimulus controllers for state tracking, selection, transfer payloads, and remote loading state, but it does not currently implement a full WAI-ARIA tree or treegrid keyboard interaction model.

Host apps remain responsible for page-level keyboard flow, focus order, table captions, action buttons, and any shortcut keys they add around TreeView. If a host app needs full treegrid keyboard navigation, treat that as an explicit application feature rather than assuming TreeView provides it automatically.

The shipped stylesheet adds a lightweight `.tree-toggle__action:focus-visible` ring and background so keyboard focus is easier to track in quick-start setups. Host apps can override or replace that baseline in copied CSS.

## Baseline row-state styling

The shipped stylesheet also adds lightweight row-state cues for quick-start setups:

- selected rows via `aria-selected="true"` and `.is-selected`
- current rows via `aria-current="page"`
- collapsed rows via `aria-expanded="false"` and `.is-collapsed`
- loading, error, and drop-target rows via row state classes such as `.is-loading`, `.is-error`, and `.is-drop-target`

These defaults are intentionally thin. They are meant to make common states easier to distinguish before a host app adds its own theme, not to provide a finished product design system.

## `aria-controls`

A toggle link may reveal or hide multiple descendant rows, and in lazy-loading cases the controlled descendants may not exist in the DOM yet. There is no single stable container that the toggle always controls.

Because of that, TreeView avoids pointing `aria-controls` at the current row or at a misleading target. Reintroduce `aria-controls` only when the controlled target is explicit, stable, and documented.

## Selection semantics

`aria-selected` means TreeView row selection state. It does not mean the host application's business checkbox state unless the host app intentionally maps those concepts together.

Checkbox payloads, disabled selection state, and submitted values remain documented in [Selection](selection.md).

## Tests

TreeView protects the documented ARIA behavior with integration specs for:

- static row `aria-level`, `aria-expanded`, and `aria-current`
- collapsed branch `aria-expanded="false"`
- checkbox selection `aria-selected`
- windowed rendering row depth and expansion state

When browser-level accessibility smoke tests are introduced, keep any rule-specific allowances or suppressions adjacent to the relevant test and point them back to this policy instead of suppressing failures without context.

## Host app responsibilities

Host apps remain responsible for page-level headings, surrounding table captions, domain-specific labels, drop targets, and any business-specific checkbox semantics.