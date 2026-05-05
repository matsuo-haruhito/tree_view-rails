import { TreeViewRemoteStateController } from "./remote_state_controller.js"
import { TreeViewSelectionController } from "./selection_controller.js"
import { TreeViewStateController } from "./state_controller.js"
import { TreeViewTransferController } from "./transfer_controller.js"

export { TreeViewRemoteStateController } from "./remote_state_controller.js"
export { TreeViewSelectionController } from "./selection_controller.js"
export { TreeViewStateController } from "./state_controller.js"
export { TreeViewTransferController } from "./transfer_controller.js"

export function registerTreeViewControllers(application) {
  application.register("tree-view-state", TreeViewStateController)
  application.register("tree-view-selection", TreeViewSelectionController)
  application.register("tree-view-transfer", TreeViewTransferController)
  application.register("tree-view-remote-state", TreeViewRemoteStateController)
}
