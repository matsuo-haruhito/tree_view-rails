# Styling state cues

TreeView ships `tree_view.scss` as a quick-start stylesheet. It provides reusable row structure and lightweight visual cues for selected, current, collapsed, loading, error, and drop-target states.

Host apps may override the packaged cue colors with CSS custom properties after importing TreeView:

```scss
@import "tree_view";

:root {
  --tree-view-selected-row-background: color-mix(in srgb, var(--brand-primary) 12%, transparent);
  --tree-view-current-row-accent-color: var(--brand-primary);
  --tree-view-drop-target-row-background: color-mix(in srgb, var(--brand-success) 14%, transparent);
}
```

## Documented tokens

These tokens are intended for host-app stylesheet overrides:

| Token | Applies to |
|---|---|
| `--tree-view-selected-row-background` | selected rows |
| `--tree-view-current-row-accent-color` | current row left accent |
| `--tree-view-collapsed-row-background` | collapsed rows |
| `--tree-view-loading-row-background` | loading rows |
| `--tree-view-loading-action-color` | loading row toggle action text |
| `--tree-view-error-row-background` | error and drop-disabled rows |
| `--tree-view-drop-target-row-background` | active drop target rows |
| `--tree-view-focus-outline-color` | toggle focus-visible outline |
| `--tree-view-focus-background` | toggle focus-visible background |
| `--tree-view-focus-ring-contrast-color` | toggle focus-visible contrast ring |
| `--tree-view-toggle-hover-background` | toggle hover background |
| `--tree-view-branch-line-color` | ordinary hierarchy branch lines |
| `--tree-view-current-branch-line-color` | current hierarchy branch lines |
| `--tree-view-level-background` | depth label background |
| `--tree-view-level-color` | depth label text |
| `--tree-view-hidden-count-background` | hidden descendant count background |
| `--tree-view-hidden-count-color` | hidden descendant count text |

Each token has the same fallback value that TreeView used before the token was introduced, so importing the stylesheet without overrides keeps the existing quick-start appearance.

## Boundary

TreeView owns these tokens only as a small state-cue surface for the packaged stylesheet. It does not own a complete theme system, dark-mode policy, density scale, product copy, or host-app design tokens.

For layout, spacing, row markup, and app-specific visual language, continue to use host-app CSS selectors or copied rendering as documented in the relevant feature guides.
