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

## Pull Request changed-file detection

Pull Request では、`changes` job が base branch を fetch し、`origin/${{ github.base_ref }}` と `HEAD` の merge base を探します。merge base を取得できる場合、workflow は three-dot diff の `origin/${{ github.base_ref }}...HEAD` を使い、Pull Request で変わった file を基準に routing します。merge base を解決できない場合は、fallback として `git diff --name-only origin/${{ github.base_ref }} HEAD` を使います。

得られた file list は `script/ci_changed_files_policy.mjs` に渡されます。この script が `docs_only`、`package_sensitive`、`docker_setup_sensitive`、`docs_entrypoint_sensitive`、`ci_policy_sensitive` output の source of truth です。`script/test_ci_workflow_changed_file_detection_signals.mjs` は workflow command signal を守ります。このメモは、その routing の保守者向けの意味を説明するだけで、classification logic は変更しません。

## Representative routing outputs

changed-file policy は、repository 全体の file inventory ではなく代表的な output flag を公開します。Pull Request の `changes` output を読む時は、次の例を review guidance として扱ってください。

| Output | Representative path signals | Maintainer meaning |
| --- | --- | --- |
| `docs_only` | `README.md`, `docs/**`, `AGENTS.md`, `Product Profile.md` | Pull Request は docs 形状です。ただし、他の output が focused confidence check を要求する場合があります。 |
| `package_sensitive` | `README.md`, `CHANGELOG.md`, `docs/**`, `config/public_api_manifest.yml` | packaged gem または package-facing docs confidence path を実行します。 |
| `docs_entrypoint_sensitive` | `README.md`, `docs/**`, `config/public_api_manifest.yml` | reader-facing docs または public manifest signal が変わったため、docs entrypoint signal を実行します。 |
| `ci_policy_sensitive` | `AGENTS.md`, `docs/en/ci-policy-suite.md`, `docs/ja/ci-policy-suite.md`, `.github/workflows/ci.yml`, `script/ci_changed_files_policy.mjs`, `script/test_ci_changed_files_policy.mjs` | workflow routing、CI policy suite docs、または maintainer policy signal が変わったため、CI policy guard を実行します。 |
| `docker_setup_sensitive` | `Dockerfile`, `docker-compose.yml`, `package.json`, `package-lock.json`, `.nvmrc` | Docker-based maintainer setup confidence を実行します。 |
| `mockups_changed` | `docs/mockups/**` | static mockup route が変わり、browser-smoke または gallery review が必要になる場合があります。 |
| `browser_smoke_changed` | `test/browser/**` | browser smoke definition が変わったため、executable test-surface change として扱います。 |

この表は代表例に留めます。full changed-file classifier mirror にはしないでください。executable fixture の source of truth は引き続き `script/test_ci_changed_files_policy.mjs` です。

## docs-only check retention

docs-only Pull Request でも、重い処理を意図的に skip する場合に通常の CI job 名は残します。representative Rails compatibility matrix は check surface を残し、`docs_only` が true の場合は Rails command を実行せず docs-only skip message を出します。

JavaScript job は、docs-only Pull Request かつ mockup、browser-smoke file、docs-entrypoint-sensitive file、CI-policy-sensitive file に触れていない場合だけ install と checks を skip します。`README.md`、`CHANGELOG.md`、`docs/**` のような package-facing docs は package / docs-entrypoint confidence path を通ります。`AGENTS.md` は repository-only docs ですが、agent workflow と CI observation policy を持つため CI-policy-sensitive です。`Product Profile.md` は repository-only docs で、意図的に package-sensitive / docs-entrypoint-sensitive / CI-policy-sensitive にはしていません。repository-only maintainer entrypoint smoke は、package-facing docs または他の docs-entrypoint-sensitive file が `npm run test:docs-entrypoints` を呼ぶ時に実行されます。Product Profile-only edit は、この profile を package-facing entrypoint にしないため manual-review routed のままです。

これらの保持された check 名は review / merge 判断の文脈として扱い、すべての heavyweight lane が実行された証明として扱わないでください。skipped lane は changed-file routing output と workflow run conclusion と合わせて確認します。

## GitHub Actions Dependabot lane

`.github/dependabot.yml` は Dependabot update lane の source of truth です。現在は GitHub Actions dependency update 用の `github-actions` lane を持ち、Bundler lane と同じ weekly Monday 09:00 Asia/Tokyo cadence、open pull request limit 5 で運用されています。

この automation lane は、代表 action major version を監視する CI policy guard とは分けて扱ってください。Dependabot は version update Pull Request を作成し、action-major guard は workflow action-major drift が review 時に見えるようにします。SHA pinning / allowed action policy の判断はこのメモの外で扱うため、Dependabot lane を pinning policy の決定として扱わないでください。

## Docker development setup lane

Pull Request workflow は、Docker-based maintainer setup の confidence を確認するために `docker_setup_sensitive` changed-file lane を持ちます。現在の代表 path は `Dockerfile`、`docker-compose.yml`、`package.json`、`package-lock.json`、`.nvmrc`、`.github/workflows/ci.yml` です。

この lane が true の場合、`docker_development_setup` job は `app` service を build し、container 側で Node 22、npm、`npm ci` の JavaScript install smoke を実行します。これは Docker setup 変更に対する CI routing と environment alignment の evidence であり、Docker image design 全体の review ではありません。

このメモは Docker base image、compose volume policy、Node / Ruby support policy、package scripts、CI workflow jobs、required checks、branch protection を変更しません。

## Read-only workflow permissions

Pull Request と main-push workflow は、workflow top level の `permissions: contents: read` によって `GITHUB_TOKEN` を read-only に保ちます。これにより CI は repository contents を checkout し、policy / docs / JavaScript / Ruby / Docker / package verification lane を実行できますが、各 job には default で repository write access を与えません。

`script/test_ci_workflow_permissions_signals.mjs` は、この policy 専用の guard です。top-level permissions block に `contents: read` があること、`contents: write` と `pull-requests: write` を要求していないこと、特定 job だけ token scope を広げる job-level `permissions:` override がないことを確認します。

これは CI token scope の evidence として扱ってください。branch protection、required checks、repository settings、third-party action policy、release publishing credential は設定しません。将来の workflow 変更で write permission が必要になる場合は、CI policy change として review し、このメモと guard を一緒に更新してください。

このメモは maintainer command routing だけを扱います。CI workflow jobs、required checks、branch protection、workflow permissions、lockfile policy は変更しません。
