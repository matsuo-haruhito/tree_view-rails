# Development

This page summarizes common development and maintenance tasks for the TreeView gem.

## Setup

```bash
bundle install
npm install
```

With Docker:

```bash
cp .env.example .env
docker compose build
docker compose run --rm app bundle install
docker compose run --rm app npm install
```

Use Node 22 for local JavaScript work. The repository root `.nvmrc` matches the CI JavaScript lane and is the source of truth for the recommended local Node major version. The Node version source drift spec keeps `.nvmrc`, `package.json` `engines.node`, and the workflow `node-version` value aligned without changing the current install policy.

Keep using `npm install` for now. The repository has a committed `package-lock.json`, but it is not yet refreshed in sync with `package.json`, so local setup and pull-request CI stay on `npm install` until that lockfile refresh is completed in a registry-enabled environment. See [Installation](installation.md) for the current CI and install-path summary.

## Common commands

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm run test:js
npm test
npm run test:entrypoints
npm run test:browser
```

Use `npm run test:js` when you want the same JavaScript entrypoint, unit, and browser smoke coverage as the CI JavaScript lane. Use the individual npm commands when you are narrowing a failure.

For the Rails version matrix:

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle exec rake
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rake
```

## Public API compatibility specs

Public API compatibility specs protect documented Ruby entry points, helper methods, helper option keys, grouped options, and JavaScript package-root exports from accidental removals or renames. The JavaScript entrypoint smoke also checks manifest-backed controller registrations, public event names, and documented `event.detail` key groups. Keep these specs focused on API existence and representative behavior rather than full implementation details.

When an intentional breaking change is accepted, update the public API docs and the compatibility specs together so the documented contract and test coverage stay aligned.

`config/public_api_manifest.yml` is the machine-readable source of truth for the public surface covered by compatibility checks. It currently tracks Ruby module methods, public constants, configuration options, helper names, helper option keys, toolbar action/state mapping, grouped option keys, JavaScript package-root named exports, controller registrations, public event names, and documented `event.detail` keys. When you add, rename, or remove one of those entries, update the manifest, keep `docs/en/public-api.md` and `docs/ja/public-api.md` aligned, check any README, usage page, feature doc, configuration option doc, or JavaScript event doc that names the same surface, add the user-facing note to `CHANGELOG.md` when the change materially affects adopters, and review `docs/en/release.md` / `docs/ja/release.md` when release notes or migration expectations need to change.

## JavaScript browser smoke tests

Unit-style JavaScript tests run through Vitest and jsdom with:

```bash
npm test
```

A separate entrypoint smoke check loads `app/javascript/tree_view/index.js` directly:

```bash
npm run test:entrypoints
```

That check keeps the documented controller exports and `registerTreeViewControllers` helper aligned with the importmap entrypoint. It uses Ruby to load `config/public_api_manifest.yml` and print the `javascript_package_root` section as JSON before Node assertions run, so run it from the repository root with Ruby available when you are diagnosing manifest loader failures.

Browser-level smoke tests run through Playwright with:

```bash
npm run test:browser
```

Use the browser smoke suite for representative interaction flows that need a real browser event loop, focus handling, and drag/drop APIs. Keep these tests small and stable: cover keyboard navigation, expand/collapse, checkbox cascade behavior, lazy-loading state changes, transfer payloads, and row form controls coexisting with tree behavior.

When browser-level accessibility smoke is added, do not silently suppress tree or treegrid-oriented findings. If a fixture intentionally allows a pattern because of TreeView's documented table-first policy, leave a short adjacent comment or suppression note that cites `docs/en/accessibility-semantics.md` or `docs/ja/accessibility-semantics.md` and names the specific policy being relied on, such as row-level ARIA on table rows, omitted `aria-controls`, or host-app-owned keyboard flow.

## CI policy

Pull requests run the fast Ruby checks and JavaScript tests that protect day-to-day changes:

- Ruby lint through `bundle exec standardrb`
- Ruby specs through `bundle exec rspec`
- Representative Rails compatibility checks through `gemfiles/rails_7_0.gemfile`, `gemfiles/rails_7_2.gemfile`, and `gemfiles/rails_8_0.gemfile`
- JavaScript entrypoint, unit, and browser smoke tests through `npm run test:js`

The pull-request Rails lanes intentionally skip Rails 7.1 to keep PR feedback focused on representative lower, current, and next-major coverage; the `main` push full Rails matrix is the final compatibility gate that includes Rails 7.1.

Docs-only pull requests that touch only `README.md`, `docs/**`, `Product Profile.md`, `CHANGELOG.md`, and `AGENTS.md` keep the `lint` and `pr_specs` jobs, but short-circuit the representative Rails lanes while preserving the same check names for branch protection. The JavaScript job also short-circuits for docs-only pull requests unless `docs/mockups/**` changed; mockup documentation changes still check out the branch, install Playwright, and run `npm run test:browser` so the static visual references stay covered. Pull requests that change `test/browser/**` are not docs-only shortcut candidates, and they also run the JavaScript setup plus explicit browser smoke coverage because they change the smoke suite itself. Pull requests that also touch `.github/workflows/**` do not use the docs-only shortcut and still run the normal PR lanes.

A green check suite does not by itself mean a pull request is ready to merge after `main` has moved. When a branch is `diverged`, check mergeability, changed files, risk, and how far the branch is behind. Prefer refreshing the branch and observing fresh CI when GitHub reports `mergeable: false`, when the branch is far behind, or when the pull request touches workflow definitions, public API, specs, or shared docs inventory. For small docs-only changes that are only a little behind, it is enough to confirm the changed files still apply cleanly, mergeability is true, and the named checks remain green.

Pushes to `main` also run the broader compatibility and release checks:

- Ruby version matrix
- Full Rails version matrix, including Rails 7.1
- gem package verification

## Change checklist

### Ruby API changes

- Add or update specs.
- Run `bundle exec standardrb` after Ruby file or Ruby spec edits, including connector or GitHub API edits that may bypass local editor newline handling.
- If Standard Ruby reports a mechanical formatting issue such as a missing final newline or trailing whitespace, apply the formatter or a minimal file rewrite before opening the pull request.
- Check `docs/ja/api-overview.md` and `docs/en/api-overview.md`.
- Update public API compatibility specs when documented entry points, helpers, or options are intentionally changed.
- If `config/public_api_manifest.yml` changes, update `docs/en/public-api.md` / `docs/ja/public-api.md`, then review the related README, usage docs, feature docs, JavaScript event docs, `CHANGELOG.md`, and `docs/en/release.md` / `docs/ja/release.md`.
- Update `docs/en/api.md` / `docs/ja/api.md` when needed.
- Update CHANGELOG.

### JavaScript changes

- Run `npm test`.
- Run `npm run test:entrypoints` when documented controller exports or entrypoint wiring changes.
- Run `npm run test:browser` when browser interactions, focus, drag/drop, or real form controls are affected.
- Check importmap and packaged files.
- Confirm JavaScript entrypoint compatibility and update compatibility specs when documented exports intentionally change.

### Documentation changes

Before opening a docs pull request, do a short maintenance sweep using `docs/i18n-audit.md` as the cross-language checklist.

- Confirm whether the change affects shared user-facing guidance and therefore needs matching Japanese and English updates.
- Decide whether the change needs `CHANGELOG.md`, release docs, README/docs index links, or root-level docs policy updates.
- For public API, compatibility, installation, release, or migration docs, check the update matrix in `docs/i18n-audit.md` before narrowing the PR scope.
- For focused mockup additions, renames, or removals, confirm the `docs/mockups/README.md` Files table, `docs/mockups/review-gallery.html`, and browser smoke target list describe the same inventory.
- If one language or one related doc intentionally lags, leave the mismatch visible in the PR body or a follow-up issue instead of silently relying on the docs-only CI shortcut.

- Keep Japanese and English docs in sync when practical.
- Update `docs/i18n-audit.md`.
- Decide whether root compatibility docs should remain or point to language-specific docs.
- When a pull request touches only `README.md`, `docs/**`, `Product Profile.md`, `CHANGELOG.md`, and `AGENTS.md`, confirm that the docs-only CI short-circuit is still the intended policy before relying on it.
- If a pull request also changes `.github/workflows/**`, treat it as a full CI change rather than a docs-only shortcut candidate.
- When a pull request changes `test/browser/**`, expect normal JavaScript setup and explicit `npm run test:browser` coverage even if the intent is only to maintain browser smoke specs.
- When a pull request adds, renames, or removes a focused mockup under `docs/mockups/`, keep the mockup inventory trail synchronized: update `docs/mockups/README.md`, add or adjust the `docs/mockups/review-gallery.html` card, review README and language README entry points when the recommended review flow changes, and add feature-guide links when a mockup is meant to accompany a specific guide.
- Docs-only CI skips JavaScript only when `docs/mockups/**` is unchanged. When focused mockup files change, CI runs `npm run test:browser` against the browser smoke target list, but that smoke does not prove the README Files table, review gallery, existing mockup inventory, and visual correctness are fully synchronized. If the existing mockup files and docs indexes already disagree, handle that as a separate docs follow-up instead of mixing gallery redesign or mockup HTML/CSS changes into a checklist-only PR.

## Before release

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm test`
- `npm run test:entrypoints`
- `npm run test:browser`
- `bundle exec rake build`
- gem package contents
- confirm `config/public_api_manifest.yml` still matches the documented Ruby, helper, option, JavaScript export, and event surfaces covered by public API docs
- CHANGELOG
- docs index / i18n audit

## Branch and PR policy

- Keep functional changes small.
- Larger docs-only inventory or split PRs are acceptable.
- Before opening a pull request, check whether an open pull request already closes the same issue. Look for the same `Closes #NNN` line, linked issue, and overlapping changed files.
- If a duplicate close-check finds an existing candidate, stop the new PR path and either add review/follow-up/supersede context to the existing PR or ask a maintainer to choose the adoption path.
- PR CI must pass before merge.
- Docs-only PRs may short-circuit the representative Rails and JavaScript jobs, but merge still waits for the named checks to stay green.
- PRs that change workflow definitions should be observed on a fresh head SHA before merge.
- If a PR is `diverged` from `main`, do not rely on old green CI alone; review mergeability, changed files, risk, and behind count before deciding whether to refresh.
- Full compatibility and package verification is confirmed on `main` before release decisions.