import { Application } from "@hotwired/stimulus"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { TreeViewRemoteStateController } from "./index.js"

function nextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

describe("TreeViewRemoteStateController remote state details", () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <table data-controller="tree-view-remote-state">
        <tbody>
          <tr id="remote-row" data-tree-view-state-target="node" data-tree-view-state-node-key="project:1" data-tree-children-url="/projects/1/children">
            <td><button id="remote-button" type="button">Load</button></td>
          </tr>
          <tr id="detail-row" data-tree-view-state-target="node"></tr>
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

  it("dispatches loading details from the nearest row target", () => {
    const element = document.querySelector("[data-controller='tree-view-remote-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-remote-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-remote-state:change", eventSpy)
    const row = document.querySelector("#remote-row")

    controller.loading({ target: document.querySelector("#remote-button"), detail: {} })

    expect(row.dataset.remoteState).toBe("loading")
    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toMatchObject({
      row,
      state: "loading",
      childrenUrl: "/projects/1/children",
      nodeKey: "project:1"
    })
  })

  it("dispatches loaded details and marks the row as loaded", () => {
    const element = document.querySelector("[data-controller='tree-view-remote-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-remote-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-remote-state:change", eventSpy)
    const row = document.querySelector("#remote-row")

    controller.loaded({ target: document.querySelector("#remote-button"), detail: {} })

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

  it("dispatches error details from an explicit detail row with null URL fallbacks", () => {
    const element = document.querySelector("[data-controller='tree-view-remote-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-remote-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-remote-state:change", eventSpy)
    const row = document.querySelector("#detail-row")

    controller.error({ target: document.querySelector("#remote-button"), detail: { row } })

    expect(row.dataset.remoteState).toBe("error")
    expect(document.querySelector("#remote-row").dataset.remoteState).toBeUndefined()
    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toMatchObject({
      row,
      state: "error",
      childrenUrl: null,
      nodeKey: null
    })
  })

  it("dispatches retry details and returns the row to loading state", () => {
    const element = document.querySelector("[data-controller='tree-view-remote-state']")
    const controller = application.getControllerForElementAndIdentifier(element, "tree-view-remote-state")
    const eventSpy = vi.fn()
    element.addEventListener("tree-view-remote-state:retry", eventSpy)
    const row = document.querySelector("#remote-row")
    row.dataset.remoteState = "error"

    controller.retry({ target: document.querySelector("#remote-button"), detail: {} })

    expect(row.dataset.remoteState).toBe("loading")
    expect(eventSpy).toHaveBeenCalledOnce()
    expect(eventSpy.mock.calls[0][0].detail).toMatchObject({
      row,
      childrenUrl: "/projects/1/children",
      nodeKey: "project:1"
    })
  })
})
