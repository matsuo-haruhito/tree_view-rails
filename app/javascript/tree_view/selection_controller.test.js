import { Application } from "@hotwired/stimulus"
import { afterEach, beforeEach, describe, expect, it } from "vitest"
import { TreeViewSelectionController } from "./selection_controller.js"

const flush = async () => {
  await Promise.resolve()
  await Promise.resolve()
}

const hiddenInputValues = (form) =>
  Array.from(form.querySelectorAll('input[type="hidden"][data-tree-view-selection-generated-hidden-input="true"]'))
    .map((input) => input.value)

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
})
