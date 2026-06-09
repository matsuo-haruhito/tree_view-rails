# Toolbar action HTML boundary note

This companion note supports `docs/mockups/toolbar-actions.html` review for #1573 without changing the runtime toolbar helper or the existing mockup page.

## Review question

When a host app passes `html:` or `action_html:` to toolbar helpers, reviewers need to see two ownership lanes at the same time:

- TreeView-owned hooks must remain present: `data-tree-view-toolbar`, `data-tree-view-toolbar-action`, and `data-tree-view-toolbar-disabled`.
- Host-app attributes may be added for analytics, Turbo targets, screen-specific grouping, or local styling.

The goal is to review ownership, not to define a new public manifest contract. Helper return-shape decisions remain in #1449 / PR #1516.

## Attribute ownership examples

| Scenario | TreeView-owned hook | Host-app-owned attribute | Review cue |
|---|---|---|---|
| Enabled expand action | `data-tree-view-toolbar-action="expand_all"` | `data-analytics-action="expand-all"` | Host analytics can attach without replacing the action identity hook. |
| Disabled collapse action | `data-tree-view-toolbar-disabled="true"` | `data-disabled-reason="all-rows-collapsed"` | The disabled fallback stays machine-readable while the host app owns final reason copy. |
| Current-path action | `data-tree-view-toolbar-action="collapse_to_current_path"` | `data-turbo-frame="tree_sidebar"` | Turbo targeting is host-owned; TreeView still exposes the toolbar action role. |
| Toolbar wrapper | `data-tree-view-toolbar="true"` | `data-screen="document-tree"` | Screen grouping can be added without changing the baseline toolbar hook. |

## What to check in `toolbar-actions.html`

Use the current toolbar mockup for visual states, then apply this note while reviewing the markup boundary:

- Enabled, disabled, missing-path, and current-state cues should remain visually distinct.
- Long or localized labels should wrap without hiding the action role.
- Host-app attributes should read as additive metadata, not as required TreeView behavior.
- Authorization, final labels, routes, Turbo responses, analytics policy, and permission copy stay out of the static mockup.

## Non-goals

- No runtime helper implementation change.
- No public hook export or manifest expansion.
- No real analytics, Turbo route, or authorization behavior.
- No redesign of `toolbar-actions.html` or the review gallery.
