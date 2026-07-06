# Dependabot maintainer policy

This page summarizes the current Dependabot maintenance boundary for this repository. It documents the existing queue behavior so maintainers can triage dependency PRs without changing dependency versions, CI workflow topology, or repository settings.

## Current update lanes

The repository currently uses `.github/dependabot.yml` for two weekly lanes:

- Bundler updates for the repository root.
- GitHub Actions updates for workflow actions.

Both lanes run on the Monday 09:00 Asia/Tokyo schedule and use `open-pull-requests-limit: 5`. Treat that limit as the current queue-size boundary: it keeps routine dependency update PRs from crowding out maintenance review. It is not a decision about npm dependency policy, RuboCop / Standard grouping, SHA pinning, allowed-action policy, or auto-merge.

The Bundler lane currently groups `rubocop*` updates under the `rubocop` group. Do not infer broader Standard / RuboCop grouping from this page; that remains a separate maintenance policy decision.

## GitHub Actions lane

The GitHub Actions lane is the current update path for workflow action major tags such as `actions/checkout`, `actions/setup-node`, and `ruby/setup-ruby`. The CI policy smoke keeps representative action major versions visible so action-major drift is reviewed as an intentional CI trust-boundary change instead of a silent workflow edit.

This page does not decide whether the repository should keep major tags, move to SHA pinning, or adopt an allowed-action policy. That supply-chain policy decision remains outside this docs note.

## Triage boundary

When a Dependabot PR fails, keep the first response narrow:

- Check whether the changed files are dependency metadata, lockfiles, workflow actions, or a known lint baseline drift.
- For Bundler lockfile metadata drift, use [Dependabot Bundler recovery](dependabot-bundler-recovery.md).
- For GitHub Actions update PRs, inspect the CI policy smoke before widening the PR into a workflow policy change.
- Do not mix dependency version changes, workflow topology changes, SHA pinning policy, branch protection, or auto-merge policy into a small docs or queue-size clarification PR.

## Related work

- Refs #2798 for the GitHub Actions Dependabot lane and action-major smoke relationship.
- Refs #2799 for the Dependabot open PR limit docs signal.
- Refs #2496 for the separate SHA pinning / allowed-action policy decision.
- Refs #2494 for RuboCop / Standard grouping policy.
- Refs #2168 for npm Dependabot policy.
