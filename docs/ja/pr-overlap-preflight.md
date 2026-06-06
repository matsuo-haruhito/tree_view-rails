# PR overlap preflight

Pull Request を作成する前、または事前に GitHub を確認できない環境では作成直後に、この checklist を使います。同じ Issue を close する PR や changed files の大きな重複を見える状態にし、repository settings や merge block の自動化には踏み込みません。

## 比較するもの

1. 同じ `Closes #NNN`、`Fixes #NNN`、`Refs #NNN` を持つ open Pull Request を探します。
2. 同じ parent Issue、superseded PR、replacement branch を扱っている open Pull Request がないか確認します。
3. 新しい PR 候補と既存 open PR の changed files を比較します。
4. public API manifest、TypeScript declaration、workflow、browser smoke、shared docs inventory file が重なる場合は high overlap として扱います。
5. 新しい PR が duplicate、stacked follow-up、clean replacement、意図的に分けた slice のどれかを記録します。

## connector-only handoff

ローカル checkout や GitHub CLI が使えない場合は、connector で確認できた証拠を記録します。

- 既存 open PR の番号と title
- 重複する Issue reference または closing keyword
- 比較した changed filenames
- 既存 PR が mergeable / stale / superseded のどれか
- 次の action: 新規 PR を止める、既存 PR にコメントする、replacement を作る、maintainer 判断へ回す

## 停止条件

既存 open PR が同じ Issue を close し、同じ files を触っている場合は、新規 PR 作成を止めます。ただし、新しい branch が明示的な replacement または stacked follow-up の場合は除きます。2つの PR がどちらも必要だが競合する場合は、3つ目の曖昧な実装 path を開かず、maintainer 判断を求めます。

## 記録テンプレート

```markdown
### PR overlap preflight

- Checked issue references:
- Existing PR candidates:
- Changed-file overlap:
- Classification: duplicate / stacked follow-up / replacement / separate slice
- Action taken:
```
