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

## Pull request changed-file detection

For pull requests, the `changes` job fetches the base branch, then tries to find a merge base between `origin/${{ github.base_ref }}` and `HEAD`. When the merge base is available, the workflow uses the three-dot diff, `origin/${{ github.base_ref }}...HEAD`, so routing is based on the pull request changes. If the merge base cannot be resolved, it falls back to `git diff --name-only origin/${{ github.base_ref }} HEAD`.

The resulting file list is passed to `script/ci_changed_files_policy.mjs`, which is the source of truth for the `docs_only`, `package_sensitive`, `docker_setup_sensitive`, `docs_entrypoint_sensitive`, and `ci_policy_sensitive` outputs. `script/test_ci_workflow_changed_file_detection_signals.mjs` protects the workflow command signals; this note explains the maintainer-facing meaning of that routing and does not change the classification logic.

## Representative routing outputs

The changed-file policy exposes representative output flags rather than a full repository inventory. Use these examples as review guidance when reading a pull request's `changes` output:

| Output | Representative path signals | Maintainer meaning |
| --- | --- | --- |
| `docs_only` | `README.md`, `docs/**`, `AGENTS.md`, `Product Profile.md` | The pull request is documentation-shaped, although other outputs may still request focused confidence checks. |
| `package_sensitive` | `README.md`, `CHANGELOG.md`, `docs/**`, `config/public_api_manifest.yml` | The packaged gem or package-facing docs confidence path should run. |
| `docs_entrypoint_sensitive` | `README.md`, `docs/**`, `config/public_api_manifest.yml` | Docs entrypoint signals should run because reader-facing docs or public manifest signals changed. |
| `ci_policy_sensitive` | `AGENTS.md`, `docs/en/ci-policy-suite.md`, `docs/ja/ci-policy-suite.md`, `.github/workflows/ci.yml`, `script/ci_changed_files_policy.mjs`, `script/test_ci_changed_files_policy.mjs` | CI policy guards should run because workflow routing, CI policy suite docs, or maintainer policy signals changed. |
| `docker_setup_sensitive` | `Dockerfile`, `docker-compose.yml`, `package.json`, `package-lock.json`, `.nvmrc` | Docker-based maintainer setup confidence should run. |
| `mockups_changed` | `docs/mockups/**` | Static mockup routes changed and may need browser-smoke or gallery review. |
| `browser_smoke_changed` | `test/browser/**` | Browser smoke definitions changed and should be treated as executable test-surface changes. |

Keep this table representative. Do not turn it into a full changed-file classifier mirror; `script/test_ci_changed_files_policy.mjs` remains the executable fixture source of truth.

## Docs-only check retention

Docs-only pull requests keep the usual CI job names visible even when heavyweight work is intentionally skipped. The representative Rails compatibility matrix keeps its check surface but prints the docs-only skip message instead of running the Rails command when `docs_only` is true.

The JavaScript job skips its install and checks only for docs-only pull requests that do not touch mockups, browser-smoke files, docs-entrypoint-sensitive files, or CI-policy-sensitive files. Package-facing docs such as `README.md`, `CHANGELOG.md`, and `docs/**` still route through the package/docs-entrypoint confidence path; `AGENTS.md` is repository-only docs but remains CI-policy-sensitive; `Product Profile.md` is repository-only docs and is not package- or docs-entrypoint-sensitive.

Treat these retained check names as review and merge-decision context, not as proof that every heavyweight lane ran. Skipped lanes should still be read together with the changed-file routing outputs and the workflow run conclusion.

## GitHub Actions Dependabot lane

`.github/dependabot.yml` is the source of truth for the Dependabot update lanes. It currently includes a `github-actions` lane for GitHub Actions dependency updates with the same weekly Monday 09:00 Asia/Tokyo cadence and open pull request limit of 5 as the Bundler lane.

Keep that automation lane separate from the CI policy guard that watches representative action major versions. Dependabot opens version update pull requests; the action-major guard makes unexpected workflow action-major drift visible during review. The separate SHA pinning / allowed action policy decision remains tracked outside this note, so do not treat the Dependabot lane as a pinning-policy decision.

## Docker development setup lane

The pull request workflow exposes a `docker_setup_sensitive` changed-file lane for Docker-based maintainer setup confidence. The current representative paths are `Dockerfile`, `docker-compose.yml`, `package.json`, `package-lock.json`, `.nvmrc`, and `.github/workflows/ci.yml`.

When that lane is true, the `docker_development_setup` job builds the `app` service and runs the container-side JavaScript install smoke with Node 22, npm, and `npm ci`. Treat this as CI routing and environment-alignment evidence for Docker setup changes, not as a general Docker image design review.

This note does not change the Docker base image, compose volume policy, Node or Ruby support policy, package scripts, CI workflow jobs, required checks, or branch protection.

## Read-only workflow permissions

The pull request and main-push workflow keeps `GITHUB_TOKEN` read-only at the workflow top level with `permissions: contents: read`. This lets CI checkout repository contents and run the policy, docs, JavaScript, Ruby, Docker, and package verification lanes without granting repository write access to jobs by default.

`script/test_ci_workflow_permissions_signals.mjs` is the focused guard for this policy. It confirms the top-level permissions block includes `contents: read`, rejects `contents: write` and `pull-requests: write`, and rejects job-level `permissions:` overrides that would silently widen the token for one job.

Treat this as CI token-scope evidence only. It does not configure branch protection, required checks, repository settings, third-party action policy, or release publishing credentials. If a future workflow change needs write permissions, review that as a CI policy change and update this note and the guard together.

This note is only about maintainer command routing. It does not change CI workflow jobs, required checks, branch protection, workflow permissions, or lockfile policy.