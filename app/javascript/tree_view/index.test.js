import { Application } from "@hotwired/stimulus"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import {
  TreeViewRemoteStateController,
  TreeViewSelectionController,
  TreeViewStateController,
  TreeViewTransferController
} from "./index.js"

function nextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

describe("TreeViewStateController", () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <table
        data-controller="tree-view-state"
        data-tree-view-state-view-key-value="projects#index"
        data-tree-view-state-keyboard-value="true"
      >
        <tbody>
          <tr id="row-1" data-tree-view-state-target="node" data-tree-view-state-node-key="project:1" data-tree-view-state-expanded="true">
            <td><button class="remove-button" type="button"></button></td>
          </tr>
          <tr id="row-2" data-tree-view-state-target="node" data-tree-view-state-node-key="project:2" data-tree-view-state-expanded="false">
            <td><button class="show-button" type="button"></button></td>
          </tr>
        </tbody>
      </table>
    `

    application = Application.start()
    application.register("tree-view-state", TreeViewStateController)
    await nextFrame()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("reports expanded keys and prepares keyboard focus targets", () => {
    const element = document.querySelector("[data-controller='tree-view-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")

    expect(controller.expandedKeys()).toEqual(["project:1"])
    expect(element.tabIndex).toBe(0)
    expect(document.querySelector("#row-1").tabIndex).toBe(-1)
  })

  it("updates expansion state from toggle events", () => {
    const element = document.querySelector("[data-controller='tree-view-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")
    const row = document.querySelector("#row-2")

    controller.markExpanded({ target: row })

    expect(row.dataset.treeViewStateExpanded).toBe("true")
    expect(controller.expandedKeys()).toEqual(["project:1", "project:2"])
  })

  it("uses keyboard navigation to activate row toggles", () => {
    const element = document.querySelector("[data-controller='tree-view-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-state")
    const button = document.querySelector("#row-2 .show-button")
    const click = vi.spyOn(button, "click")

    controller.keydown({
      key: "ArrowRight",
      preventDefault: vi.fn(),
      target: document.querySelector("#row-2")
    })

    expect(click).toHaveBeenCalledOnce()
  })
})

describe("TreeViewSelectionController", () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <table data-controller="tree-view-selection" data-tree-view-selection-cascade-value="true" data-tree-view-selection-indeterminate-value="true" data-tree-view-selection-max-count-value="2">
        <tbody>
          <tr data-tree-depth="0">
            <td><input class="tree-selection-checkbox" type="checkbox" value='{"key":"project:1"}'></td>
          </tr>
          <tr data-tree-depth="1">
            <td><input class="tree-selection-checkbox" type="checkbox" value='{"key":"project:2"}'></td>
          </tr>
          <tr data-tree-depth="1">
            <td><input class="tree-selection-checkbox" type="checkbox" value='{"key":"project:3"}' disabled></td>
          </tr>
          <tr data-tree-depth="0">
            <td><input class="tree-selection-checkbox" type="checkbox" value='{"key":"project:4"}'></td>
          </tr>
        </tbody>
      </table>
    `

    application = Application.start()
    application.register("tree-view-selection", TreeViewSelectionController)
    await nextFrame()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("cascades parent selection to enabled descendants only", () => {
    const element = document.querySelector("[data-controller='tree-view-selection']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-selection")
    const [parent, enabledChild, disabledChild] = document.querySelectorAll(".tree-selection-checkbox")

    parent.checked = true
    controller.toggle({ target: parent })

    expect(enabledChild.checked).toBe(true)
    expect(disabledChild.checked).toBe(false)
  })

  it("sets parent indeterminate state from partially selected descendants", () => {
    const element = document.querySelector("[data-controller='tree-view-selection']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-selection")
    const [parent, child] = document.querySelectorAll(".tree-selection-checkbox")

    child.checked = true
    controller.updateIndeterminateStates()

    expect(parent.checked).toBe(true)
    expect(parent.indeterminate).toBe(false)
  })

  it("enforces maxCount and dispatches limit-exceeded", () => {
    const element = document.querySelector("[data-controller='tree-view-selection']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-selection")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-selection:limit-exceeded", eventSpy)
    const checkboxes = document.querySelectorAll(".tree-selection-checkbox:not(:disabled)")

    checkboxes[0].checked = true
    checkboxes[1].checked = true
    checkboxes[2].checked = true
    controller.toggle({ target: checkboxes[2] })

    expect(checkboxes[2].checked).toBe(false)
    expect(eventSpy).toHaveBeenCalledOnce()
  })

  it("parses selected payloads and reports invalid JSON payloads", () => {
    const element = document.querySelector("[data-controller='tree-view-selection']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-selection")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-selection:invalid-payload", eventSpy)
    const [valid] = document.querySelectorAll(".tree-selection-checkbox")
    valid.checked = true

    expect(controller.selectedPayloads()).toEqual([{ key: "project:1" }])

    valid.value = "not-json"

    expect(controller.selectedPayloads()).toEqual([])
    expect(eventSpy).toHaveBeenCalledOnce()
  })
})

describe("TreeViewRemoteStateController", () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <table data-controller="tree-view-remote-state">
        <tbody>
          <tr id="remote-row" data-tree-view-state-target="node" data-tree-view-state-node-key="project:1" data-tree-children-url="/projects/1/children"></tr>
        </tbody>
      </table>
    `

    application = Application.start()
    application.register("tree-view-remote-state", TreeViewRemoteStateController)
    await nextFrame()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("marks rows as loaded and dispatches state change detail", () => {
    const element = document.querySelector("[data-controller='tree-view-remote-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-remote-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-remote-state:change", eventSpy)
    const row = document.querySelector("#remote-row")

    controller.loaded({ target: row, detail: {} })

    expect(row.dataset.remoteState).toBe("loaded")
    expect(row.dataset.treeLoaded).toBe("true")
    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toMatchObject({
      row,
      state: "loaded",
      childrenUrl: "/projects/1/children",
      nodeKey: "project:1"
    })
  })

  it("dispatches retry with children URL and node key", () => {
    const element = document.querySelector("[data-controller='tree-view-remote-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-remote-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-remote-state:retry", eventSpy)
    const row = document.querySelector("#remote-row")

    controller.retry({ target: row, detail: {} })

    expect(row.dataset.remoteState).toBe("loading")
    expect(eventSpy.mock.calls[0][0].detail).toMatchObject({
      row,
      childrenUrl: "/projects/1/children",
      nodeKey: "project:1"
    })
  })
})

describe("TreeViewTransferController", () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <table data-controller="tree-view-transfer">
        <tbody>
          <tr id="source-row" data-tree-depth="0" data-tree-transfer-payload='{"key":"project:1"}'></tr>
          <tr id="target-row" data-tree-depth="0" data-tree-transfer-payload='{"key":"project:2"}'></tr>
        </tbody>
      </table>
    `

    application = Application.start()
    application.register("tree-view-transfer", TreeViewTransferController)
    await nextFrame()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("writes transfer payloads during drag start", () => {
    const element = document.querySelector("[data-controller='tree-view-transfer']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-transfer")
    const dataTransfer = {
      effectAllowed: null,
      setData: vi.fn()
    }

    controller.start({ target: document.querySelector("#source-row"), dataTransfer })

    expect(dataTransfer.effectAllowed).toBe("move")
    expect(dataTransfer.setData).toHaveBeenCalledWith("application/json", JSON.stringify({ key: "project:1" }))
  })

  it("dispatches drop payloads with calculated position", () => {
    const element = document.querySelector("[data-controller='tree-view-transfer']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-transfer")
    const targetRow = document.querySelector("#target-row")
    targetRow.getBoundingClientRect = () => ({ top: 0, height: 90 })
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-transfer:drop", eventSpy)

    controller.drop({
      target: targetRow,
      clientY: 80,
      preventDefault: vi.fn(),
      dataTransfer: {
        getData: (type) => (type === "application/json" ? JSON.stringify({ key: "project:1" }) : "")
      }
    })

    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toMatchObject({
      sourcePayload: { key: "project:1" },
      targetPayload: { key: "project:2" },
      position: "after",
      targetRow
    })
  })
})
