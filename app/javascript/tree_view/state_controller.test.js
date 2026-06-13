import { Application } from "@hotwired/stimulus"
import { afterEach, describe, expect, it, vi } from "vitest"
import { TreeViewStateController } from "./state_controller.js"

function nextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

function renderTree({ keyboard = false } = {}) {
  document.body.innerHTML = `
    <section
      id="tree"
      data-controller="tree-view-state"
      data-tree-view-state-view-key-value="project-tree"
      ${keyboard ? 'data-tree-view-state-keyboard-value="true"' : ""}>
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

function makeVisible(...ids) {
  ids.forEach((id) => {
    Object.defineProperty(document.getElementById(id), "offsetParent", {
      configurable: true,
      get: () => document.body
    })
  })
}

function keydown(controller, target, key) {
  const event = new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true })
  Object.defineProperty(event, "target", { configurable: true, value: target })
  controller.keydown(event)
  return event
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
      expandedKeys: ["project:1"],
      reason: "connect"
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
      expandedKeys: [],
      reason: "collapsed"
    })

    document.getElementById("project-2").dataset.treeViewStateExpanded = "true"
    controller.refresh()

    expect(eventSpy).toHaveBeenCalledTimes(2)
    expect(eventSpy.mock.calls[1][0].detail).toEqual({
      viewKey: "project-tree",
      expandedKeys: ["project:2"],
      reason: "refresh"
    })
  })

  it("moves Home and End focus to the first and last visible rows", async () => {
    const element = renderTree({ keyboard: true })
    application = Application.start()
    application.register("tree-view-state", TreeViewStateController)
    await nextFrame()

    makeVisible("project-1", "project-2")

    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")
    const first = document.getElementById("project-1")
    const second = document.getElementById("project-2")
    const hidden = document.getElementById("missing-key")

    second.focus()
    const homeEvent = keydown(controller, second, "Home")
    expect(homeEvent.defaultPrevented).toBe(true)
    expect(document.activeElement).toBe(first)

    const endEvent = keydown(controller, first, "End")
    expect(endEvent.defaultPrevented).toBe(true)
    expect(document.activeElement).toBe(second)
    expect(document.activeElement).not.toBe(hidden)
  })

  it("leaves Home and End events from interactive targets alone", async () => {
    const element = renderTree({ keyboard: true })
    application = Application.start()
    application.register("tree-view-state", TreeViewStateController)
    await nextFrame()

    makeVisible("project-1", "project-2")

    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")
    const first = document.getElementById("project-1")
    const button = document.getElementById("project-2-toggle")

    button.focus()
    const event = keydown(controller, button, "Home")

    expect(event.defaultPrevented).toBe(false)
    expect(document.activeElement).toBe(button)
    expect(document.activeElement).not.toBe(first)
  })

  it("does not handle Home and End when keyboard navigation is disabled", async () => {
    const element = renderTree()
    application = Application.start()
    application.register("tree-view-state", TreeViewStateController)
    await nextFrame()

    makeVisible("project-1", "project-2")

    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")
    const first = document.getElementById("project-1")
    const second = document.getElementById("project-2")

    first.tabIndex = -1
    second.tabIndex = -1
    first.focus()
    const event = keydown(controller, first, "End")

    expect(event.defaultPrevented).toBe(false)
    expect(document.activeElement).toBe(first)
  })
})
