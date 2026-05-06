import { describe, expect, it, vi } from "vitest"
import {
  TreeViewRemoteStateController,
  TreeViewSelectionController,
  TreeViewStateController,
  TreeViewTransferController,
  registerTreeViewControllers
} from "./index.js"

describe("TreeView JavaScript public API compatibility", () => {
  it("keeps documented controller exports available", () => {
    expect(TreeViewStateController).toBeTypeOf("function")
    expect(TreeViewSelectionController).toBeTypeOf("function")
    expect(TreeViewTransferController).toBeTypeOf("function")
    expect(TreeViewRemoteStateController).toBeTypeOf("function")
  })

  it("keeps registerTreeViewControllers available and registers documented identifiers", () => {
    const application = { register: vi.fn() }

    registerTreeViewControllers(application)

    expect(application.register).toHaveBeenCalledWith("tree-view-state", TreeViewStateController)
    expect(application.register).toHaveBeenCalledWith("tree-view-selection", TreeViewSelectionController)
    expect(application.register).toHaveBeenCalledWith("tree-view-transfer", TreeViewTransferController)
    expect(application.register).toHaveBeenCalledWith("tree-view-remote-state", TreeViewRemoteStateController)
  })
})
