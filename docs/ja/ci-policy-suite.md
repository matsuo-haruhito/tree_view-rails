# CI policy suite

このメモは、workflow routing、CI observation guidance、lockfile drift guard、CI-policy-sensitive な maintainer docs を変更する Pull Request で使う、保守者向けの狭い CI policy suite を説明します。

## 使う場面

広い JavaScript entrypoint suite ではなく、CI policy guard だけを確認したい場合は full suite を実行します。

```bash
npm run test:ci-policy
```

package script は先に suite self-test を実行し、その後に設定済みの CI policy guard group を実行します。group list の source of truth は `script/test_ci_policy_suite.mjs` として扱ってください。

## 絞り込み実行

1つの guard failure を切り分ける場合は、suite option を使います。

```bash
node script/test_ci_policy_suite.mjs --list
node script/test_ci_policy_suite.mjs --only <group-or-index>
node script/test_ci_policy_suite.mjs --self-test
```

`--list` は利用できる guard group を順番付きで表示します。`--only` は 1-based index、完全一致の group 名、大文字小文字を問わない group 名、または一意に絞れる部分一致の group 名を受け付けます。unknown、ambiguous、範囲外の値は非 0 終了し、available groups と `--list` の案内を表示します。

## 登録 self-test

CI policy guard script を追加または rename した場合は、CI に頼る前に suite の `checks` array を更新するか、明示的な exclusion を残してください。self-test は candidate script を走査し、登録済み script が suite から見えることを確認します。未登録 candidate がある場合は missing script path を表示して失敗します。

## GitHub Actions Dependabot lane

`.github/dependabot.yml` は Dependabot update lane の source of truth です。現在は GitHub Actions dependency update 用の `github-actions` lane を持ち、Bundler lane と同じ weekly Monday 09:00 Asia/Tokyo cadence、open pull request limit 5 で運用されています。

この automation lane は、代表 action major version を監視する CI policy guard とは分けて扱ってください。Dependabot は version update Pull Request を作成し、action-major guard は workflow action-major drift が review 時に見えるようにします。SHA pinning / allowed action policy の判断はこのメモの外で扱うため、Dependabot lane を pinning policy の決定として扱わないでください。

このメモは maintainer command routing だけを扱います。CI workflow jobs、required checks、branch protection、workflow permissions、lockfile policy は変更しません。
