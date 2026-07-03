# CI Policy Suite

This repository keeps CI policy coverage in `script/test_ci_policy_docs_routing.mjs` so that docs, package scripts, workflow wiring, and the prelude runner stay aligned.

## Suite registration policy

The package script runs the standalone LICENSE package-sensitive prelude first (`node script/test_license_package_sensitive_signal.mjs`). The package script runs the suite self-test first after that prelude, then runs the configured CI policy guard groups. Treat this ordering as intentional: the standalone prelude remains visible for focused debugging, while the suite runner owns the broader CI policy contract.

When you add a CI policy guard, add it to the suite registry and keep the package script pointed at the suite runner instead of adding another top-level package script entry. The docs routing self-test checks this section so wording drift is caught before CI silently skips a guard.

## Guard groups

The suite currently covers:

- docs entrypoint routing
- package-sensitive runtime checks
- route/package ownership signals
- accessibility and keyboard contracts
- build and release metadata

Keep guard names specific enough for CI logs to show which policy failed.
