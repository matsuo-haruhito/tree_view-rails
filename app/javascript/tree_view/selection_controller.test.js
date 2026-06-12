import { Application } from "@hotwired/stimulus"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import { TreeViewSelectionController } from "./selection_controller.js"

const flush = async () => {
  await Promise.resolve()
  await Promise.resolve()
}

const hiddenInputs = (form) =>
  Array.from(form.querySelectorAll('input[type="hidden"][data-tree-view-selection-generated-hidden-input="true"]'))

const hiddenInputValues = (form) => hiddenInputs(form).map((input) => input.value)

describe("TreeViewSelectionController", () => {
  let application

  beforeEach(() => {
    document.body.innerHTML = ""
    application = Application.start()
    application.register("tree-view-selection", TreeViewSelectionController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("mirrors checked payloads into hidden inputs on the nearest form", async () => {
    document.body.innerHTML = `
      <form id="bulk-form">
        <table>
          <tbody
            data-controller="tree-view-selection"
            data-action="change->tree-view-selection#toggle"
            data-tree-view-selection-hidden-input-name-value="selected_nodes[]">
            <tr data-tree-depth="0">
              <td>
                <input
                  id="node-1"
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  value='{"id":1,"kind":"document"}'>
              </td>
            </tr>
            <tr data-tree-depth="0">
              <td>
                <input
                  id="node-2"
                  class="tree-selection-checkbox"
                  type="checkbox"
                  value='{"id":2,"kind":"document"}'>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    `

    await flush()

    const form = document.getElementById("bulk-form")
    expect(hiddenInputValues(form)).toEqual(['{"id":1,"kind":"document"}'])

    const second = document.getElementById("node-2")
    second.checked = true
    second.dispatchEvent(new Event("change", { bubbles: true }))

    await flush()

    expect(hiddenInputValues(form)).toEqual([
      '{"id":1,"kind":"document"}',
      '{"id":2,"kind":"document"}'
    ])
  })

  it("syncs selected count targets on connect and checkbox changes", async () => {
    document.body.innerHTML = `
      <table>
        <tbody
          data-controller="tree-view-selection"
          data-action="change->tree-view-selection#toggle">
          <tr data-tree-depth="0">
            <td>
              <span id="count" data-tree-view-selection-target="selectedCount">pending</span>
              <span id="toolbar-count" data-tree-view-selection-target="selectedCount">pending</span>
            </td>
            <td>
              <input
                id="node-1"
                class="tree-selection-checkbox"
                type="checkbox"
                checked
                value='{"id":1}'>
            </td>
          </tr>
          <tr data-tree-depth="0">
            <td></td>
            <td>
              <input
                id="node-2"
                class="tree-selection-checkbox"
                type="checkbox"
                value='{"id":2}'>
            </td>
          </tr>
        </tbody>
      </table>
    `

    await flush()

    expect(document.getElementById("count").textContent).toBe("1")
    expect(document.getElementById("toolbar-count").textContent).toBe("1")

    const second = document.getElementById("node-2")
    second.checked = true
    second.dispatchEvent(new Event("change", { bubbles: true }))

    await flush()

    expect(document.getElementById("count").textContent).toBe("2")
    expect(document.getElementById("toolbar-count").textContent).toBe("2")
  })

  it("keeps selected count targets aligned after max-count rollback", async () => {
    document.body.innerHTML = `
      <table>
        <tbody
          data-controller="tree-view-selection"
          data-action="change->tree-view-selection#toggle"
          data-tree-view-selection-max-count-value="1">
          <tr data-tree-depth="0">
            <td><span id="count" data-tree-view-selection-target="selectedCount">pending</span></td>
            <td>
              <input
                id="node-1"
                class="tree-selection-checkbox"
                type="checkbox"
                checked
                value='{"id":1}'>
            </td>
          </tr>
          <tr data-tree-depth="0">
            <td></td>
            <td>
              <input
                id="node-2"
                class="tree-selection-checkbox"
                type="checkbox"
                value='{"id":2}'>
            </td>
          </tr>
        </tbody>
      </table>
    `

    await flush()

    const second = document.getElementById("node-2")
    second.checked = true
    second.dispatchEvent(new Event("change", { bubbles: true }))

    await flush()

    expect(second.checked).toBe(false)
    expect(document.getElementById("count").textContent).toBe("1")
  })

  it("skips disabled and invalid payloads when syncing hidden inputs", async () => {
    document.body.innerHTML = `
      <form id="bulk-form">
        <table>
          <tbody
            data-controller="tree-view-selection"
            data-tree-view-selection-hidden-input-name-value="selected_nodes[]">
            <tr data-tree-depth="0">
              <td>
                <input
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  value='{"id":1}'>
              </td>
            </tr>
            <tr data-tree-depth="0">
              <td>
                <input
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  value='not-json'>
              </td>
            </tr>
            <tr data-tree-depth="0">
              <td>
                <input
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  disabled
                  value='{"id":3}'>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    `

    await flush()

    const form = document.getElementById("bulk-form")
    expect(hiddenInputValues(form)).toEqual(['{"id":1}'])
  })

  it("removes only its own generated hidden inputs when disconnected", async () => {
    document.body.innerHTML = `
      <form id="bulk-form">
        <table>
          <tbody
            id="first-selection"
            data-controller="tree-view-selection"
            data-tree-view-selection-hidden-input-name-value="selected_nodes[]">
            <tr data-tree-depth="0">
              <td>
                <input
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  value='{"id":1}'>
              </td>
            </tr>
          </tbody>
          <tbody
            id="second-selection"
            data-controller="tree-view-selection"
            data-tree-view-selection-hidden-input-name-value="selected_nodes[]">
            <tr data-tree-depth="0">
              <td>
                <input
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  value='{"id":2}'>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    `

    await flush()

    const form = document.getElementById("bulk-form")
    expect(hiddenInputValues(form)).toEqual(['{"id":1}', '{"id":2}'])

    document.getElementById("first-selection").remove()
    await flush()

    expect(hiddenInputValues(form)).toEqual(['{"id":2}'])
    expect(hiddenInputs(form)[0].dataset.treeViewSelectionSourceId).toBe(
      document.getElementById("second-selection").dataset.treeViewSelectionSourceId
    )
  })

  it("does not raise on disconnect when hidden input sync is disabled", async () => {
    document.body.innerHTML = `
      <form id="bulk-form">
        <table>
          <tbody id="selection" data-controller="tree-view-selection">
            <tr data-tree-depth="0">
              <td>
                <input
                  class="tree-selection-checkbox"
                  type="checkbox"
                  checked
                  value='{"id":1}'>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    `

    await flush()

    const selection = document.getElementById("selection")
    expect(() => selection.remove()).not.toThrow()
    await flush()

    expect(hiddenInputValues(document.getElementById("bulk-form"))).toEqual([])
  })
})
