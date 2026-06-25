# CI policy suite

このメモは、workflow routing、CI observation guidance、lockfile drift guard、CI-policy-sensitive な maintainer docs を変更する Pull Request で使う、保守者向けの狭い CI policy suite を説明します。

## 使う場面

広い JavaScript entrypoint suite ではなく、CI policy guard だけを確認したい場合は full suite を実行します。

```bash
npm run test:ci-policy
```

package script は先に suite self-test を実行し、その後に設定済みの CI policy guard group を実行します。suite 移行の review 中に `package.json` 側へ互換用の直接 guard command が残っていても、group list の source of truth は `script/test_ci_policy_suite.mjs` として扱ってください。

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

このメモは maintainer command routing だけを扱います。CI workflow jobs、required checks、branch protection、workflow permissions、lockfile policy は変更しません。
