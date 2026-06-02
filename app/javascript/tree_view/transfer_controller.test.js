import { Application } from "@hotwired/stimulus"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { TreeViewTransferController } from "./index.js"

function nextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

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

  function controller() {
    const element = document.querySelector("[data-controller='tree-view-transfer']")
    return application.getControllerForElementAndIdentifier(element, "tree-view-transfer")
  }

  it("calculates before, inside, and after drop positions", () => {
    const targetRow = document.querySelector("#target-row")
    targetRow.getBoundingClientRect = () => ({ top: 10, height: 90 })

    expect(controller().dropPosition({ clientY: 20 }, targetRow)).toBe("before")
    expect(controller().dropPosition({ clientY: 55 }, targetRow)).toBe("inside")
    expect(controller().dropPosition({ clientY: 95 }, targetRow)).toBe("after")
  })

  it("dispatches invalid-payload when a row payload is not valid JSON", () => {
    const element = document.querySelector("[data-controller='tree-view-transfer']")
    const targetRow = document.querySelector("#target-row")
    const invalidPayloadSpy = vi.fn()
    const dataTransfer = { dropEffect: null }
    targetRow.dataset.treeTransferPayload = "not-json"
    targetRow.getBoundingClientRect = () => ({ top: 0, height: 90 })
    element.addEventListener("tree-view-transfer:invalid-payload", invalidPayloadSpy)

    controller().over({
      target: targetRow,
      clientY: 45,
      preventDefault: vi.fn(),
      dataTransfer
    })

    expect(dataTransfer.dropEffect).toBe("move")
    expect(invalidPayloadSpy).toHaveBeenCalledOnce()
    expect(invalidPayloadSpy.mock.calls[0][0].detail).toMatchObject({
      value: "not-json",
      row: targetRow
    })
  })

  it("dispatches invalid-transfer and keeps the drop event boundary intact", () => {
    const element = document.querySelector("[data-controller='tree-view-transfer']")
    const targetRow = document.querySelector("#target-row")
    const invalidTransferSpy = vi.fn()
    const dropSpy = vi.fn()
    targetRow.getBoundingClientRect = () => ({ top: 0, height: 90 })
    element.addEventListener("tree-view-transfer:invalid-transfer", invalidTransferSpy)
    element.addEventListener("tree-view-transfer:drop", dropSpy)

    controller().drop({
      target: targetRow,
      clientY: 80,
      preventDefault: vi.fn(),
      dataTransfer: {
        getData: (type) => (type === "application/json" ? "not-json" : "")
      }
    })

    expect(invalidTransferSpy).toHaveBeenCalledOnce()
    expect(invalidTransferSpy.mock.calls[0][0].detail).toEqual({ value: "not-json" })
    expect(dropSpy).toHaveBeenCalledOnce()
    expect(dropSpy.mock.calls[0][0].detail).toMatchObject({
      sourcePayload: null,
      targetPayload: { key: "project:2" },
      position: "after",
      targetRow
    })
  })
})
