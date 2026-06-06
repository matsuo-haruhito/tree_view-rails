# PR overlap preflight

Use this checklist before opening a pull request, or immediately after creating one when the environment cannot inspect GitHub beforehand. It keeps duplicate close intent and high changed-file overlap visible without changing repository settings or blocking merges automatically.

## What to compare

1. Search open pull requests for the same `Closes #NNN`, `Fixes #NNN`, or `Refs #NNN` issue reference.
2. Check whether another open pull request mentions the same parent issue, superseded pull request, or replacement branch.
3. Compare changed files for the candidate pull request and the existing open pull request.
4. Treat overlap as high when both pull requests touch the same public API manifest, TypeScript declaration, workflow, browser smoke, or shared docs inventory file.
5. Record whether the new pull request is a duplicate, a stacked follow-up, a clean replacement, or an intentionally separate slice.

## Connector-only handoff

When a local checkout or GitHub CLI is unavailable, record the connector evidence instead:

- existing open pull request number and title
- overlapping issue references or closing keywords
- changed filenames compared
- whether the existing pull request is mergeable, stale, or already superseded
- next action: stop new PR creation, comment on the existing PR, open a replacement, or ask a maintainer to choose

## Stop conditions

Stop the new pull request path when an existing open pull request already closes the same issue and touches the same files, unless the new branch is an explicit replacement or stacked follow-up. If the two pull requests both contain useful but conflicting changes, ask for maintainer direction instead of opening a third unlabelled implementation path.

## Evidence template

```markdown
### PR overlap preflight

- Checked issue references:
- Existing PR candidates:
- Changed-file overlap:
- Classification: duplicate / stacked follow-up / replacement / separate slice
- Action taken:
```
