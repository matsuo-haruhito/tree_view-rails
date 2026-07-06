# Dependabot maintainer policy

このページは、この repository の現在の Dependabot maintenance boundary を整理します。dependency version、CI workflow topology、repository settings を変更せず、保守者が dependency PR を切り分けるための現行 queue behavior を文書化します。

## 現在の update lane

この repository は `.github/dependabot.yml` で次の 2 つの weekly lane を使っています。

- repository root の Bundler updates
- workflow actions 向けの GitHub Actions updates

どちらの lane も Monday 09:00 Asia/Tokyo schedule で動き、`open-pull-requests-limit: 5` を使います。この limit は現在の queue-size boundary として扱ってください。routine dependency update PR が maintenance review を押し流さないようにするための境界です。npm dependency policy、RuboCop / Standard grouping、SHA pinning、allowed-action policy、auto-merge の判断ではありません。

Bundler lane は現在、`rubocop*` updates を `rubocop` group にまとめます。このページから Standard / RuboCop のより広い grouping 方針を読み取らないでください。その判断は別の maintenance policy decision として扱います。

## GitHub Actions lane

GitHub Actions lane は、`actions/checkout`、`actions/setup-node`、`ruby/setup-ruby` など workflow action major tags の現在の update path です。CI policy smoke は代表的な action major version を見える状態に保ち、action-major drift を静かな workflow edit ではなく意図的な CI trust-boundary change として review できるようにします。

このページは、repository が major tag を維持するか、SHA pinning に進むか、allowed-action policy を採用するかを決めるものではありません。その supply-chain policy decision はこの docs note の外に残します。

## triage boundary

Dependabot PR が失敗した場合、最初の対応は狭く保ってください。

- changed files が dependency metadata、lockfiles、workflow actions、既知の lint baseline drift のどれかを確認する
- Bundler lockfile metadata drift では [Dependabot Bundler 復旧手順](dependabot-bundler-recovery.md) を使う
- GitHub Actions update PR では、workflow policy change に広げる前に CI policy smoke を確認する
- 小さな docs や queue-size clarification PR に、dependency version change、workflow topology change、SHA pinning policy、branch protection、auto-merge policy を混ぜない

## 関連作業

- GitHub Actions Dependabot lane と action-major smoke の関係は #2798 を参照してください。
- Dependabot open PR limit docs signal は #2799 を参照してください。
- SHA pinning / allowed-action policy decision は #2496 として分けて扱います。
- RuboCop / Standard grouping policy は #2494 として分けて扱います。
- npm Dependabot policy は #2168 として分けて扱います。
