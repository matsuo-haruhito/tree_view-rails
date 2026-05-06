# Design policy

This page summarizes the TreeView gem design policy and responsibility boundaries.

## Core policy

TreeView provides primitives for building tree UIs in Rails host apps.

The gem includes:

- tree traversal
- Rails helpers, partials, and contexts
- UI configuration builders
- general-purpose hooks such as selection, lazy loading, and windowed rendering
- JavaScript controller hooks
- diagnostics

The host app owns:

- CRUD
- authorization
- business actions
- queries, filtering, and pagination
- Turbo Stream responses
- design system integration
- domain-specific validation

## Why keep the boundary explicit?

Tree UI patterns are shared across many apps, but operations and business rules differ by application.

TreeView therefore provides display and integration boundaries, while business behavior remains in the host app.

## API design

- Public APIs should be easy for host apps to call directly.
- Internal helpers should stay small.
- Builders accept callables, and invalid values should raise clear errors.
- Backward-incompatible changes should be documented in release notes.

## JavaScript design

JavaScript controllers provide TreeView-specific browser-side integration hooks.

- selection payload collection
- cascade and indeterminate updates
- transfer payloads
- remote loading state

Fetch behavior, business actions, API requests, and error messages are host app responsibilities.

## Documentation policy

Docs should clearly describe responsibility boundaries that users may otherwise misunderstand.

- What TreeView provides
- What the host app implements
- Code examples
- Responsibility boundary tables

## Decision criteria

When deciding whether a feature belongs in the gem, use these questions.

| Question | Fits the gem | Belongs in host app |
|---|---|---|
| Is it common across host apps? | yes | no |
| Is it independent of domain rules? | yes | no |
| Is it a UI primitive? | yes | no |
| Does it mutate data? | no | yes |
| Does it need authorization? | no | yes |
| Does it need server-side querying? | no | yes |
