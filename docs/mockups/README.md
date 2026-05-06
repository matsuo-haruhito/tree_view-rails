# TreeView mockups

This directory contains static HTML/CSS mockups for reviewing TreeView's baseline output without running a Rails app.

These files are intentionally small, reviewable assets in the gem repository. They show representative DOM structure, CSS hooks, ARIA attributes, and row states emitted by the reusable TreeView primitives.

They are **not** a complete Rails application and should not grow into host-app CRUD, query, authorization, seed data, or controller examples. Full playground/application examples belong in `matsuo-haruhito/tree_view-rails-demo` once that demo repository is public.

## Files

| File | Covers |
|---|---|
| [default-tree.html](default-tree.html) | Default table/tree output, checkbox selection, expanded/collapsed rows, badges, depth labels, row actions, and baseline CSS. |
| [interaction-states.html](interaction-states.html) | Lazy-loading, loading, error/retry, next-page, and drag/drop visual states. |
| [default-tree.css](default-tree.css) | Shared CSS for the static mockups. |

## Review policy

- Prefer static HTML/CSS that can be inspected directly in pull-request diffs.
- Keep mockups product-neutral and free of host-app business behavior.
- Add screenshots only when visual regression review needs them; the source HTML/CSS should remain the canonical mockup.
- If a mockup needs Rails routes, controllers, database records, authorization, or Turbo responses to make sense, it belongs in a playground app rather than this directory.
