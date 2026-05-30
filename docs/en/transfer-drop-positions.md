# Transfer Drop Positions

`TreeViewTransferDropPositions` is the package-root public export for the documented transfer drop position names.

```js
import { TreeViewTransferDropPositions } from "tree_view"

if (event.detail.position === TreeViewTransferDropPositions.inside) {
  // Handle an inside drop target in the host app.
}
```

The object is intentionally narrow:

- `before` maps to `"before"`
- `inside` maps to `"inside"`
- `after` maps to `"after"`

Use these values when handling `tree-view-transfer:drag-over` or `tree-view-transfer:drop` events and you want to avoid copying raw position strings in host-app code or tests.

This export only names the values carried by `event.detail.position`. It does not add a reorder policy, persistence helper, authorization decision, or drag/drop calculation hook. TreeView still emits the same event names and detail keys, and host apps still own whether a drop is allowed and how a move is saved.
