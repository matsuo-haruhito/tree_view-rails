# CI policy suite

This note explains the narrow CI policy suite used by maintainers when a pull request changes workflow routing, CI observation guidance, lockfile drift guards, or CI-policy-sensitive maintainer docs.

## When to use it

Run the full CI policy suite when you need to confirm the policy guards without running the broader JavaScript entrypoint suite:

```bash
npm run test:ci-policy
```

The package script runs the suite self-test first and then runs the configured CI policy guard groups. Treat `script/test_ci_policy_suite.mjs` as the source of truth for the group list.

## Targeted runs

Use the suite options when you are narrowing one guard failure:

```bash
node script/test_ci_policy_suite.mjs --list
node script/test_ci_policy_suite.mjs --only <group-or-index>
node script/test_ci_policy_suite.mjs --self-test
```

`--list` prints the available guard groups in order. `--only` accepts the 1-based index, exact group name, case-insensitive group name, or a unique partial group name. Unknown, ambiguous, or out-of-range values fail and print the available groups plus the `--list` hint.

## Registration self-test

When adding or renaming a CI policy guard script, update the suite `checks` array or document an explicit exclusion before relying on CI. The self-test scans candidate scripts, confirms that registered scripts stay visible through the suite, and fails with the missing script path when a candidate is not registered.

## GitHub Actions Dependabot lane

`.github/dependabot.yml` is the source of truth for the Dependabot update lanes. It currently includes a `github-actions` lane for GitHub Actions dependency updates with the same weekly Monday 09:00 Asia/Tokyo cadence and open pull request limit of 5 as the Bundler lane.

Keep that automation lane separate from the CI policy guard that watches representative action major versions. Dependabot opens version update pull requests; the action-major guard makes unexpected workflow action-major drift visible during review. The separate SHA pinning / allowed action policy decision remains tracked outside this note, so do not treat the Dependabot lane as a pinning-policy decision.

This note is only about maintainer command routing. It does not change CI workflow jobs, required checks, branch protection, workflow permissions, or lockfile policy.
