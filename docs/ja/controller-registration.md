# Controller registration

TreeView は、通常の導入向けに `registerTreeViewControllers(application)` を公開し、host app が独自の登録 flow を持つ場合向けに `TreeViewControllerEntries` を公開します。

TreeView bundled controller を documented order のまま全て登録したい場合は、従来どおり default helper を使ってください。

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

一部 controller だけを登録したい場合、host app 側の boot sequence に TreeView controller 登録を組み込みたい場合、または identifier と controller class の対応を写経せず参照したい場合は、`TreeViewControllerEntries` を使います。

```js
import { TreeViewControllerEntries } from "tree_view"

for (const { identifier, controller } of TreeViewControllerEntries) {
  application.register(identifier, controller)
}
```

各 entry は以下を持ちます。

- `key`: controller entry の manifest key
- `identifier`: documented Stimulus identifier
- `controller`: exported controller class

`TreeViewControllerEntries` の順序は `registerTreeViewControllers(application)` と同じで、state、client、selection、transfer、remote state の順です。host app は entry を filter / reorder できますが、その場合の挙動変更は host app 側の責務です。

この export は identifier の rename、controller behavior、event payload、登録 policy を変更しません。既存の documented controller pairing を machine-readable に参照できるようにする追加 API です。
