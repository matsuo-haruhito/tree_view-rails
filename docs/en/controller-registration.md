# Controller registration

TreeView exports `registerTreeViewControllers(application)` for the default setup and `TreeViewControllerEntries` for host apps that need a custom registration flow.

Use the default helper when the host app wants TreeView to register every bundled controller in the documented order:

```js
import { registerTreeViewControllers } from "tree_view"

registerTreeViewControllers(application)
```

Use `TreeViewControllerEntries` when the host app needs to register only part of the controller set, merge TreeView registration into an app-owned boot sequence, or inspect the documented identifier/controller pairing without copying TreeView's pairing logic:

```js
import { TreeViewControllerEntries } from "tree_view"

for (const { identifier, controller } of TreeViewControllerEntries) {
  application.register(identifier, controller)
}
```

Each entry contains:

- `key`: the manifest key for the controller entry
- `identifier`: the documented Stimulus identifier
- `controller`: the exported controller class

`TreeViewControllerEntries` follows the same order as `registerTreeViewControllers(application)`: state, client, selection, transfer, then remote state. Custom boot code may filter or reorder entries, but the host app owns the behavior change when it does so.

This export does not rename identifiers, change controller behavior, change event payloads, or add a new registration policy. It is a machine-readable version of the existing documented controller pairing.
