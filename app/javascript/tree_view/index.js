import { TreeViewClientController } from "./client_controller.js"
import { TreeViewRemoteStateController } from "./remote_state_controller.js"
import { TreeViewSelectionController } from "./selection_controller.js"
import { TreeViewStateController } from "./state_controller.js"
import { TreeViewTransferController } from "./transfer_controller.js"

export { TreeViewClientController } from "./client_controller.js"
export { TreeViewRemoteStateController } from "./remote_state_controller.js"
export { TreeViewSelectionController } from "./selection_controller.js"
export { TreeViewStateController } from "./state_controller.js"
export { TreeViewTransferController } from "./transfer_controller.js"

export const TreeViewControllerIdentifiers = Object.freeze({
  state: "tree-view-state",
  client: "tree-view-client",
  selection: "tree-view-selection",
  transfer: "tree-view-transfer",
  remoteState: "tree-view-remote-state"
})

export const TreeViewControllerEntries = Object.freeze([
  Object.freeze({
    key: "state",
    identifier: TreeViewControllerIdentifiers.state,
    controller: TreeViewStateController
  }),
  Object.freeze({
    key: "client",
    identifier: TreeViewControllerIdentifiers.client,
    controller: TreeViewClientController
  }),
  Object.freeze({
    key: "selection",
    identifier: TreeViewControllerIdentifiers.selection,
    controller: TreeViewSelectionController
  }),
  Object.freeze({
    key: "transfer",
    identifier: TreeViewControllerIdentifiers.transfer,
    controller: TreeViewTransferController
  }),
  Object.freeze({
    key: "remoteState",
    identifier: TreeViewControllerIdentifiers.remoteState,
    controller: TreeViewRemoteStateController
  })
])

export function registerTreeViewControllers(application) {
  application.register("tree-view-state", TreeViewStateController)
  application.register("tree-view-client", TreeViewClientController)
  application.register("tree-view-selection", TreeViewSelectionController)
  application.register("tree-view-transfer", TreeViewTransferController)
  application.register("tree-view-remote-state", TreeViewRemoteStateController)
}
