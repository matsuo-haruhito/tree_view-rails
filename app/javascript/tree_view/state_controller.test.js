import { Application } from "@hotwired/stimulus"
import { afterEach, describe, expect, it, vi } from "vitest"
import { TreeViewStateController } from "./state_controller.js"

function nextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

function renderTree() {
  document.body.innerHTML = `
    <section
      id="tree"
      data-controller="tree-view-state"
      data-tree-view-state-view-key-value="project-tree">
      <div
        id="project-1"
        data-tree-view-state-target="node"
        data-tree-view-state-node-key="project:1"
        data-tree-view-state-expanded="true">
        <button id="project-1-toggle" type="button">Toggle</button>
      </div>
      <div
        id="project-2"
        data-tree-view-state-target="node"
        data-tree-view-state-node-key="project:2"
        data-tree-view-state-expanded="false">
        <button id="project-2-toggle" type="button">Toggle</button>
      </div>
      <div
        id="missing-key"
        data-tree-view-state-target="node"
        data-tree-view-state-expanded="true">
        <button id="missing-key-toggle" type="button">Toggle</button>
      </div>
    </section>
  `

  return document.getElementById("tree")
}

describe("TreeViewStateController state-changed details", () => {
  let application

  afterEach(() => {
    if (application) application.stop()
    application = null
    document.body.innerHTML = ""
  })

  it("dispatches viewKey and expandedKeys when the controller connects", async () => {
    const element = renderTree()
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-state:state-changed", eventSpy)

    application = Application.start()
    application.register("tree-view-state", TreeViewStateController)
    await nextFrame()

    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toEqual({
      viewKey: "project-tree",
      expandedKeys: ["project:1"]
    })
  })

  it("updates expandedKeys when nodes collapse and refresh dispatches the current payload", async () => {
    const element = renderTree()
    application = Application.start()
    application.register("tree-view-state", TreeViewStateController)
    await nextFrame()

    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-state:state-changed", eventSpy)

    controller.markCollapsed({ target: document.getElementById("project-1-toggle") })

    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toEqual({
      viewKey: "project-tree",
      expandedKeys: []
    })

    document.getElementById("project-2").dataset.treeViewStateExpanded = "true"
    controller.refresh()

    expect(eventSpy).toHaveBeenCalledTimes(2)
    expect(eventSpy.mock.calls[1][0].detail).toEqual({
      viewKey: "project-tree",
      expandedKeys: ["project:2"]
    })
  })
})
