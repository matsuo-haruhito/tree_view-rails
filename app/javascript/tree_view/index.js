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

export const TreeViewEventNames = Object.freeze({
  state: Object.freeze({
    stateChanged: "tree-view-state:state-changed"
  }),
  selection: Object.freeze({
    change: "tree-view-selection:change",
    selected: "tree-view-selection:selected",
    limitExceeded: "tree-view-selection:limit-exceeded",
    invalidPayload: "tree-view-selection:invalid-payload"
  }),
  remoteState: Object.freeze({
    change: "tree-view-remote-state:change",
    retry: "tree-view-remote-state:retry"
  }),
  transfer: Object.freeze({
    dragStart: "tree-view-transfer:drag-start",
    dragOver: "tree-view-transfer:drag-over",
    drop: "tree-view-transfer:drop",
    invalidPayload: "tree-view-transfer:invalid-payload",
    invalidTransfer: "tree-view-transfer:invalid-transfer"
  })
})

export const TreeViewControllerIdentifiers = Object.freeze({
  state: "tree-view-state",
  client: "tree-view-client",
  selection: "tree-view-selection",
  transfer: "tree-view-transfer",
  remoteState: "tree-view-remote-state"
})

export function registerTreeViewControllers(application) {
  application.register("tree-view-state", TreeViewStateController)
  application.register("tree-view-client", TreeViewClientController)
  application.register("tree-view-selection", TreeViewSelectionController)
  application.register("tree-view-transfer", TreeViewTransferController)
  application.register("tree-view-remote-state", TreeViewRemoteStateController)
}
