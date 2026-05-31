import { Application } from "@hotwired/stimulus"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import { TreeViewSelectionController } from "./index.js"

function nextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

describe("TreeViewSelectionController hidden input source isolation", () => {
  let application

  beforeEach(async () => {
    document.body.innerHTML = `
      <form id="bulk-form">
        <table
          id="tree-a"
          data-controller="tree-view-selection"
          data-tree-view-selection-hidden-input-name-value="selected_nodes[]"
        >
          <tbody>
            <tr data-tree-depth="0">
              <td>
                <input
                  id="node-a"
                  class="tree-selection-checkbox"
                  type="checkbox"
                  value='{ "id": "a" }'
                  checked
                >
              </td>
            </tr>
          </tbody>
        </table>
        <table
          id="tree-b"
          data-controller="tree-view-selection"
          data-tree-view-selection-hidden-input-name-value="selected_nodes[]"
        >
          <tbody>
            <tr data-tree-depth="0">
              <td>
                <input
                  id="node-b"
                  class="tree-selection-checkbox"
                  type="checkbox"
                  value='{ "id": "b" }'
                  checked
                >
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    `

    application = Application.start()
    application.register("tree-view-selection", TreeViewSelectionController)
    await nextFrame()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  function generatedHiddenInputs() {
    return Array.from(
      document.querySelectorAll("input[data-tree-view-selection-generated-hidden-input='true']")
    )
  }

  it("keeps generated hidden inputs scoped to the controller that created them", () => {
    const treeA = document.querySelector("#tree-a")
    const treeB = document.querySelector("#tree-b")
    const controllerA = application.getControllerForElementAndIdentifier(treeA, "tree-view-selection")
    const controllerB = application.getControllerForElementAndIdentifier(treeB, "tree-view-selection")
    const initialInputs = generatedHiddenInputs()

    expect(initialInputs).toHaveLength(2)
    expect(initialInputs.map((input) => input.name)).toEqual(["selected_nodes[]", "selected_nodes[]"])
    expect(initialInputs.map((input) => JSON.parse(input.value))).toEqual([{ id: "a" }, { id: "b" }])
    expect(new Set(initialInputs.map((input) => input.dataset.treeViewSelectionSourceId)).size).toBe(2)

    document.querySelector("#node-a").checked = false
    controllerA.refresh()

    const remainingInputs = generatedHiddenInputs()

    expect(remainingInputs).toHaveLength(1)
    expect(JSON.parse(remainingInputs[0].value)).toEqual({ id: "b" })
    expect(remainingInputs[0].dataset.treeViewSelectionSourceId).toBe(treeB.dataset.treeViewSelectionSourceId)
    expect(remainingInputs[0].dataset.treeViewSelectionSourceId).not.toBe(treeA.dataset.treeViewSelectionSourceId)
    expect(controllerB.selectedPayloads()).toEqual([{ id: "b" }])
  })
})
