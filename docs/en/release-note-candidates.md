# Release note candidate collector

`script/release_note_candidates.rb` is a release preparation helper for collecting links that a maintainer may want to review before writing GitHub Release notes.

It is intentionally a candidate collector only:

- It does not edit `CHANGELOG.md`.
- It does not decide the final release notes.
- It does not tag, publish, or create a GitHub Release.
- It does not replace the release preparation PR described in `docs/en/release.md`.

## Date window

Use a date window when you want GitHub Search to return merged pull requests and closed issues directly:

```bash
ruby script/release_note_candidates.rb --repo matsuo-haruhito/tree_view-rails --since 2026-06-01
```

This mode queries:

- merged pull requests with `merged:>=YYYY-MM-DD`
- closed issues with `closed:>=YYYY-MM-DD`

Set `GITHUB_TOKEN` when you need a higher API rate limit or private repository access. Public repositories can usually be checked without a token, subject to GitHub API limits.

## Since tag

Use a tag when you want a local release review based on commit references after the previous release tag:

```bash
ruby script/release_note_candidates.rb --repo matsuo-haruhito/tree_view-rails --since-tag v0.1.0
```

This mode compares the tag to `HEAD`, extracts `#123` style references from commit messages, and resolves those numbers as pull requests or issues. It is useful as a fallback when a date window is not obvious, but it only finds references that appear in commit messages.

## Review boundary

Treat the output as a checklist for maintainer review. During the release preparation PR, compare it with `CHANGELOG.md` and the merged PR history, then manually decide which items are notable enough for GitHub Release notes.
