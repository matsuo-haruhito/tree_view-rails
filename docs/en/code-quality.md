# Code quality

This page summarizes code quality expectations for the TreeView gem.

## Core policy

TreeView is integrated into host apps, so clear APIs, backward compatibility, and diagnosability are important.

Priorities:

- keep public and internal APIs clearly separated
- raise clear errors for invalid options early
- avoid mixing host app responsibilities into the gem
- update tests and docs together
- prefer implementations that avoid stack overflows on large trees

## Lint

Ruby lint uses Standard Ruby.

```bash
bundle exec standardrb
```

Pull request CI runs this before merge.

## Tests

Ruby specs:

```bash
bundle exec rspec
```

Pull request CI also runs Ruby specs before merge so Ruby behavior and public API regressions are caught early.

JavaScript tests:

```bash
npm test
```

JavaScript tests run in the broader `main` CI and should be run locally for JavaScript changes.

Package verification:

```bash
bundle exec rake build
```

Package verification runs in the broader `main` CI before release decisions.

## Error messages

Invalid builder or option values should produce messages that help host app developers identify the cause.

Good errors should make clear:

- which option is invalid
- which type or value is expected
- the target node or node key when available

## Public API compatibility

When a public API changes, check:

- `docs/public-api.md`
- `docs/ja/api-overview.md`
- `docs/en/api-overview.md`
- `docs/api.md`
- CHANGELOG

When a breaking change is necessary, release notes should include migration guidance.

## Documentation quality

User-facing docs should include, when practical:

- minimal examples
- option tables
- responsibility boundaries
- what the host app must implement
- links to related docs

## Review checklist

- API names match existing docs.
- Examples match the actual API.
- Root docs, `docs/ja`, `docs/en`, and the i18n audit stay consistent.
- PR CI lint and Ruby specs pass.
- Full compatibility and package verification on `main` remains green before release decisions.
