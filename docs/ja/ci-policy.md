# CI Policy

この repository は、Pull Request CI を絞りつつ、`main` での release confidence を保ちます。

## Rails Matrix Boundary

Pull Request は Rails 7.0、Rails 7.2、Rails 8.0 の representative Rails matrix を実行します。Rails 7.1 は main-push full Rails matrix に残します。

この分割により、通常の Pull Request は速く保ちながら、merge 後には supported Rails lane をすべて確認できます。この境界を変更する場合は CI policy change として扱い、`.github/workflows/ci.yml`、このページ、英語の peer page、`script/test_ci_matrix_boundary_signals.mjs` を一緒に更新してください。

## Verification

workflow matrix topology または CI policy docs を変更した後は `npm run test:ci-policy` を実行してください。`CI matrix boundary signals` group は、Pull Request の representative lanes、main-push full Rails lanes、対応する docs signals を確認します。
