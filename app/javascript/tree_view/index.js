import { Controller } from "@hotwired/stimulus"

export class TreeViewStateController extends Controller {
  static targets = ["node"]
  static values = {
    viewKey: String
  }

  connect() {
    this.dispatchStateChanged()
  }

  expandedKeys() {
    return this.nodeTargets
      .filter((node) => node.dataset.treeViewStateExpanded === "true")
      .map((node) => node.dataset.treeViewStateNodeKey)
      .filter((key) => key && key.length > 0)
  }

  markExpanded(event) {
    this.setExpandedFromEvent(event, true)
  }

  markCollapsed(event) {
    this.setExpandedFromEvent(event, false)
  }

  refresh() {
    this.dispatchStateChanged()
  }

  setExpandedFromEvent(event, expanded) {
    const node = this.findNodeFromEvent(event)
    if (!node) return

    node.dataset.treeViewStateExpanded = expanded ? "true" : "false"
    this.dispatchStateChanged()
  }

  findNodeFromEvent(event) {
    const target = event.target
    if (!target || !target.closest) return null

    return target.closest("[data-tree-view-state-target~='node']")
  }

  dispatchStateChanged() {
    this.dispatch("state-changed", {
      detail: {
        viewKey: this.hasViewKeyValue ? this.viewKeyValue : null,
        expandedKeys: this.expandedKeys()
      }
    })
  }
}

export class TreeViewSelectionController extends Controller {
  static values = {
    cascade: Boolean,
    indeterminate: Boolean
  }

  connect() {
    this.updateIndeterminateStates()
  }

  selectedPayloads() {
    return this.selectedCheckboxes()
      .map((checkbox) => this.parsePayload(checkbox))
      .filter((payload) => payload !== null)
  }

  submit(event) {
    if (event) event.preventDefault()

    this.dispatch("selected", {
      detail: {
        payloads: this.selectedPayloads()
      }
    })
  }

  refresh() {
    this.updateIndeterminateStates()
    this.dispatch("selected", {
      detail: {
        payloads: this.selectedPayloads()
      }
    })
  }

  toggle(event) {
    const checkbox = event.target
    if (!checkbox || !checkbox.matches || !checkbox.matches(".tree-selection-checkbox")) return

    if (this.cascadeValue) this.setDescendantChecked(checkbox, checkbox.checked)
    this.updateIndeterminateStates()
    this.refresh()
  }

  selectedCheckboxes() {
    return Array.from(
      this.element.querySelectorAll(".tree-selection-checkbox:checked:not(:disabled)")
    )
  }

  parsePayload(checkbox) {
    try {
      return JSON.parse(checkbox.value)
    } catch (_error) {
      this.dispatch("invalid-payload", {
        detail: {
          value: checkbox.value,
          checkbox
        }
      })
      return null
    }
  }

  setDescendantChecked(checkbox, checked) {
    this.descendantCheckboxes(checkbox).forEach((descendant) => {
      if (descendant.disabled) return

      descendant.checked = checked
      descendant.indeterminate = false
    })
  }

  updateIndeterminateStates() {
    if (!this.indeterminateValue) return

    this.checkboxes()
      .sort((left, right) => this.depth(right) - this.depth(left))
      .forEach((checkbox) => this.updateIndeterminateState(checkbox))
  }

  updateIndeterminateState(checkbox) {
    const descendants = this.descendantCheckboxes(checkbox).filter((descendant) => !descendant.disabled)
    if (descendants.length === 0) {
      checkbox.indeterminate = false
      return
    }

    const checkedCount = descendants.filter((descendant) => descendant.checked).length
    const partialCount = descendants.filter((descendant) => descendant.indeterminate).length
    const allChecked = checkedCount === descendants.length
    const partiallyChecked = checkedCount > 0 || partialCount > 0

    checkbox.checked = allChecked
    checkbox.indeterminate = partiallyChecked && !allChecked
  }

  descendantCheckboxes(checkbox) {
    const row = checkbox.closest("tr[data-tree-depth]")
    if (!row) return []

    const rowDepth = this.depthFromRow(row)
    const descendants = []
    let current = row.nextElementSibling

    while (current) {
      const currentDepth = this.depthFromRow(current)
      if (currentDepth <= rowDepth) break

      const descendant = current.querySelector(".tree-selection-checkbox")
      if (descendant) descendants.push(descendant)
      current = current.nextElementSibling
    }

    return descendants
  }

  checkboxes() {
    return Array.from(this.element.querySelectorAll(".tree-selection-checkbox"))
  }

  depth(checkbox) {
    const row = checkbox.closest("tr[data-tree-depth]")
    return this.depthFromRow(row)
  }

  depthFromRow(row) {
    if (!row) return 0

    const depth = Number.parseInt(row.dataset.treeDepth || "0", 10)
    return Number.isNaN(depth) ? 0 : depth
  }
}

export function registerTreeViewControllers(application) {
  application.register("tree-view-state", TreeViewStateController)
  application.register("tree-view-selection", TreeViewSelectionController)
}
