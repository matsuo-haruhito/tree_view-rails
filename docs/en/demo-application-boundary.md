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

## Current entry points

Until the demo repository is public, this boundary page is the durable handoff point for demo-link questions. The intentional entry points are:

- root `README.md`, near the mockup and empty-state overview
- root `docs/README.md`, beside the static mockups and language-specific docs map
- `docs/en/README.md` and `docs/ja/README.md`, as the language-specific user-facing docs index entries

Treat `docs/mockups/README.md` as the source for static mockup review policy. It may point readers back to this boundary, but it should not become a demo app catalog or collect private demo links. Treat release docs as a checklist for shipped gem changes; only add demo-app wording there if a release actually changes public docs navigation or publication status.

## Publication checklist

When the demo repository becomes public, update only the docs entry points that help readers choose between the gem contract and the example host app.

Update candidates:

- Root `README.md`: add one short link near the existing mockup / demo boundary paragraph.
- Root `docs/README.md`: add the demo app as an optional entry point only if it is useful beside the static mockups and language-specific docs.
- `docs/en/README.md` and `docs/ja/README.md`: add a language-specific link only when the demo app docs are ready for that audience.
- This page: replace the temporary "until public" wording with a link and keep the example-host-app boundary visible.

Do not update:

- `docs/mockups/README.md` as if the mockups are becoming the demo app. Keep that page focused on static HTML/CSS review assets.
- Feature guides that describe reusable TreeView APIs unless the demo app shows a specific already-documented feature.
- Public API, release, or package docs; the demo app is not part of the gem compatibility contract.

Before adding links, confirm the repository is public, the linked README is usable without private access, and the wording does not promise CRUD, authorization, seed data, or host-app workflows as TreeView gem behavior.

## Non-goals

- Adding Rails controllers, routes, models, seed data, or authorization examples to this gem repository
- Turning `docs/mockups/` into a playground application
- Documenting application-specific file-manager behavior as TreeView behavior