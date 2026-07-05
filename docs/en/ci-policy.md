# CI Policy

This repository keeps pull-request CI focused while preserving release confidence on `main`.

## Rails Matrix Boundary

Pull requests run the representative Rails matrix for Rails 7.0, Rails 7.2, and Rails 8.0. Rails 7.1 stays in the main-push full Rails matrix.

The split keeps ordinary pull requests fast while still checking every supported Rails lane after merge. Treat changes to this boundary as CI policy changes: update `.github/workflows/ci.yml`, this page, the Japanese peer page, and `script/test_ci_matrix_boundary_signals.mjs` together.

## Verification

Run `npm run test:ci-policy` after changing workflow matrix topology or CI policy docs. The `CI matrix boundary signals` group checks the pull-request representative lanes, the main-push full Rails lanes, and the matching docs signals.
