# Code quality

This document records lightweight quality checks for maintainers.

## Current baseline

The default project check is:

```bash
bundle exec rake
```

Release checks also include:

```bash
bundle exec rake build
```

## Linting policy

Linting should be added gradually.

Preferred order:

1. Ruby linting for library and helper code.
2. ERB/template checks for gem partials.
3. JavaScript checks for TreeView browser helpers.
4. Markdown checks for docs.

Avoid large style-only rewrites in the same PR as behavior changes.

## CI guidance

A new lint task should be fast, deterministic, and documented before it is required in CI.

If a lint rule would require broad churn, add it as a separate PR after the main feature work has settled.
