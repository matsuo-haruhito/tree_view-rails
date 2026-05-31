# Demo application boundary

TreeView keeps reusable tree rendering primitives in this gem repository. End-to-end Rails application examples belong outside this repository so the gem docs do not grow into CRUD, authorization, seed data, or product-specific workflow documentation.

## Static mockups vs. a real demo app

Use the static [TreeView mockups](../mockups/README.md) when you need to review baseline DOM structure, CSS hooks, ARIA placement, and representative interaction states without running Rails.

Use a real Rails demo application when you need examples that require routes, controllers, database records, authorization, Turbo responses, seed data, or complete host-app workflows.

## Link policy

Do not add a direct demo repository link from this gem's public docs until the demo repository is publicly available. Until then, keep public entry points focused on:

- the static mockups for visual and DOM references
- feature guides for reusable TreeView APIs and hooks
- host-app responsibility boundaries for CRUD, authorization, routes, and business actions

When a public demo repository is available, add a short link from the root README or docs index and keep the wording clear that the demo app is an example host application, not part of TreeView's gem contract.

## Non-goals

- Adding Rails controllers, routes, models, seed data, or authorization examples to this gem repository
- Turning `docs/mockups/` into a playground application
- Documenting application-specific file-manager behavior as TreeView behavior
