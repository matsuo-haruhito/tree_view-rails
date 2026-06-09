# Release note candidate collector

`script/release_note_candidates.rb` は、GitHub Release notes に載せる候補リンクを release preparation 時に確認するための補助 script です。

この script は candidate collector に限定します。

- `CHANGELOG.md` は編集しません。
- 最終的な release notes を自動判断しません。
- tag 作成、gem publish、GitHub Release 作成は行いません。
- `docs/ja/release.md` に書かれている release preparation PR の代わりにはしません。

## Date window

期間が決まっている場合は、GitHub Search から merged pull request と closed issue を直接集めます。

```bash
ruby script/release_note_candidates.rb --repo matsuo-haruhito/tree_view-rails --since 2026-06-01
```

この mode は次を検索します。

- `merged:>=YYYY-MM-DD` の merged pull requests
- `closed:>=YYYY-MM-DD` の closed issues

API rate limit を上げたい場合や private repository を見る場合は `GITHUB_TOKEN` を設定してください。public repository では token なしでも確認できますが、GitHub API の rate limit に依存します。

## Since tag

前回 release tag 以降の commit reference を起点に確認したい場合は tag を指定します。

```bash
ruby script/release_note_candidates.rb --repo matsuo-haruhito/tree_view-rails --since-tag v0.1.0
```

この mode は tag と `HEAD` を compare し、commit message 内の `#123` 形式の参照を pull request / issue として解決します。期間を決めにくいときの fallback として使えますが、commit message に出てこない issue / PR は候補に入りません。

## Review boundary

出力は maintainer review 用 checklist として扱います。release preparation PR では、この候補一覧、`CHANGELOG.md`、merged PR history を見比べ、GitHub Release notes に載せるべき項目を人間が判断してください。
