# Accessibility semantics

This page records TreeView's current accessibility policy for table-based tree rows.

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

## `aria-controls`

A toggle link may reveal or hide multiple descendant rows, and in lazy-loading cases the controlled descendants may not exist in the DOM yet. There is no single stable container that the toggle always controls.

Because of that, TreeView avoids pointing `aria-controls` at the current row or at a misleading target. Reintroduce `aria-controls` only when the controlled target is explicit, stable, and documented.

## Selection semantics

`aria-selected` means TreeView row selection state. It does not mean the host application's business checkbox state unless the host app intentionally maps those concepts together.

Checkbox payloads, disabled selection state, and submitted values remain documented in [Selection](selection.md).

## Host app responsibilities

Host apps remain responsible for page-level headings, surrounding table captions, domain-specific labels, drop targets, and any business-specific checkbox semantics.
