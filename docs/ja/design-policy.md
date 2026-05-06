# Design policy

このページでは、TreeView gem の設計方針と責務範囲を整理します。

## 基本方針

TreeViewは、Rails host appでtree UIを構築するためのprimitiveを提供します。

gemに含めるもの:

- tree構造のtraversal
- Rails helper / partial / context
- UI設定用builder
- selection、lazy loading、windowed renderingなどの汎用hook
- JavaScript controller hook
- diagnostics

host appに残すもの:

- CRUD
- authorization
- business action
- query / filtering / pagination
- Turbo Stream response
- design system integration
- domain-specific validation

## なぜ境界を分けるか

tree UIは多くのアプリで共通しますが、操作や業務ルールはアプリごとに異なります。

そのため、TreeViewは「表示と連携のための境界」を提供し、業務処理はhost appに残します。

## API design

- 公開APIはhost appから直接使いやすくする。
- 内部helperは可能な限り小さく保つ。
- builderはcallableを受け取り、invalid valueは明確なerrorにする。
- 後方互換性を壊す変更はrelease notesに明記する。

## JavaScript design

JavaScript controllerは、TreeView固有のbrowser-side integration hookを提供します。

- selection payload collection
- cascade / indeterminate update
- transfer payload
- remote loading state

fetch、business action、API request、error messageはhost app側で実装します。

## Documentation policy

利用者が迷いやすい責務境界はdocsに明記します。

- TreeViewが提供するもの
- host appが実装するもの
- code example
- responsibility boundary table

## 判断基準

新しい機能をgemに入れるか迷った場合は、以下を確認します。

| Question | Gemに入れやすい | Host appに残すべき |
|---|---|---|
| 複数host appで共通か | yes | no |
| domain ruleに依存しないか | yes | no |
| UI primitiveか | yes | no |
| data mutationを伴うか | no | yes |
| authorizationが必要か | no | yes |
| server-side queryが必要か | no | yes |
