# Selection checkbox hooks

`TreeViewSelectionCheckboxHooks` exposes the documented selection checkbox DOM hooks from the package root.

Use this export when host-app JavaScript or browser-level tests need to refer to the rendered checkbox class or disabled-reason data attribute without copying raw strings.

```js
import { TreeViewSelectionCheckboxHooks } from "tree_view"

const checkboxSelector = `.${TreeViewSelectionCheckboxHooks.checkboxClass}`
const disabledReasonAttribute = TreeViewSelectionCheckboxHooks.disabledReasonAttribute
```

Documented keys:

- `checkboxClass`: `tree-selection-checkbox`
- `disabledReasonAttribute`: `data-tree-selection-disabled-reason`

This surface is intentionally limited to the rendered selection checkbox hook. It does not include broader selection markup, generated hidden-input bookkeeping attributes, payload semantics, event payloads, or host-app business actions.

Use `TreeViewSelectionDataHooks` for host-authored `tree-view-selection` controller value attributes such as `data-tree-view-selection-hidden-input-name-value`. Use `TreeViewSelectionCheckboxHooks` only for the checkbox element emitted by TreeView's selection cell partial.

The selection controller still collects only checked and enabled selection checkboxes. Disabled filtering, invalid payload handling, cascade behavior, hidden input sync, and submitted payload parsing are unchanged.
