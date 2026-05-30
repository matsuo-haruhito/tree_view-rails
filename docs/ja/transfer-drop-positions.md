# Transfer Drop Positions

`TreeViewTransferDropPositions` は、documented な transfer drop position 名を参照するための package-root public export です。

```js
import { TreeViewTransferDropPositions } from "tree_view"

if (event.detail.position === TreeViewTransferDropPositions.inside) {
  // host app 側で inside drop target を扱います。
}
```

この object は intentionally narrow です。

- `before` は `"before"` を返します
- `inside` は `"inside"` を返します
- `after` は `"after"` を返します

`tree-view-transfer:drag-over` または `tree-view-transfer:drop` を扱う host app code / test で、raw string を写経せずに `event.detail.position` を比較したい場合に使ってください。

この export は `event.detail.position` に入る値の名前だけを表します。reorder policy、persistence helper、authorization decision、drag/drop calculation hook は追加しません。TreeView が emit する event name と detail key は変わらず、drop を許可するか、move をどう保存するかは host app 側の責務です。
