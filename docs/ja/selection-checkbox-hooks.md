# Selection checkbox hooks

`TreeViewSelectionCheckboxHooks` は、package root から documented selection checkbox DOM hook を参照するための export です。

host app の JavaScript や browser-level test が、描画済み checkbox class や disabled reason data attribute を raw string として写経したくない場合に使います。

```js
import { TreeViewSelectionCheckboxHooks } from "tree_view"

const checkboxSelector = `.${TreeViewSelectionCheckboxHooks.checkboxClass}`
const disabledReasonAttribute = TreeViewSelectionCheckboxHooks.disabledReasonAttribute
```

documented key:

- `checkboxClass`: `tree-selection-checkbox`
- `disabledReasonAttribute`: `data-tree-selection-disabled-reason`

この surface は、TreeView が描画する selection checkbox hook だけに限定します。selection markup 全体、generated hidden-input bookkeeping attribute、payload semantics、event payload、host app の business action は含めません。

`data-tree-view-selection-hidden-input-name-value` のような host-authored `tree-view-selection` controller value attribute には `TreeViewSelectionDataHooks` を使ってください。`TreeViewSelectionCheckboxHooks` は TreeView の selection cell partial が出力する checkbox element だけを対象にします。

selection controller は引き続き checked かつ enabled な selection checkbox だけを収集します。disabled filtering、不正 payload handling、cascade behavior、hidden input sync、submitted payload parsing は変更していません。
