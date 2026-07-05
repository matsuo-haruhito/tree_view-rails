# JavaScript package-root export の immutable contract

このメモでは、`tree_view/index.js` から公開される literal JavaScript export の reader-facing contract を整理します。

## Contract boundary

package-root の literal export は immutable reference constants です。host app は、documented string、event detail key、controller identifier、data hook name、transfer value、関連する wiring name を写経しないための参照先として使ってください。host app が mutate する設定 object ではありません。

代表的な immutable export には以下があります。

- `TreeViewEventNames`
- `TreeViewEventDetailKeys`
- `TreeViewRemoteStateValues`
- `TreeViewStateChangeReasons`
- `TreeViewTransferDropPositions`
- `TreeViewRemoteStateDataHooks`、`TreeViewToolbarDataHooks`、`TreeViewSelectionDataHooks`、`TreeViewSelectionCheckboxHooks`、`TreeViewEmptyStateHooks` などの data hook objects
- `TreeViewControllerIdentifiers`、`TreeViewControllerEntries`、`TreeViewIntegrationHooks` などの controller / integration reference objects

host app の JavaScript、browser test、shared helper が TreeView-owned string を安定して参照したい場合は、これらの package-root constant を優先してください。これらの object を mutate したり、key を追加したり、configuration container として扱ったりしないでください。host app 側で異なる挙動が必要な場合は、その挙動は host app code に置き、documented extension point を使ってください。

## Guard responsibility

runtime の frozen contract は `script/test_entrypoints.mjs` が守ります。この script は package-root export を `Object.isFrozen` で確認し、必要な場合は nested event-detail key list も frozen であることを確認します。

TypeScript declaration shape は別の compile-time aid です。`app/javascript/tree_view/index.d.ts` はこれらの export を `Readonly` object や `readonly` tuple として写し、`script/test_declaration_literal_shapes.mjs` などの declaration-shape check が manifest-backed public shape との同期を守ります。

reader-facing guidance は Public API docs と関連 feature docs に置きます。docs は、host app が raw string を写経する代わりに `TreeViewEventNames`、`TreeViewEventDetailKeys`、data hook objects などの constant をいつ参照するかを説明します。この docs guidance は runtime value、event payload shape、controller behavior、public export set を変更しません。

## 関連 docs

- [Public API](public-api.md#javascript-surface)
- [JavaScript event contract](js-events.md)
- [Drag and Drop](drag-and-drop.md)
- [Lazy Loading](lazy-loading.md)
