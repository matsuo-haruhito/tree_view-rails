import { Controller } from "@hotwired/stimulus"

export class TreeViewStateController extends Controller {
  static targets = ["node"]
  static values = {
    viewKey: String,
    keyboard: Boolean
  }

  connect() {
    if (this.keyboardValue) this.prepareKeyboardNavigation()
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
    if (this.keyboardValue) this.prepareKeyboardNavigation()
    this.dispatchStateChanged()
  }

  keydown(event) {
    if (!this.keyboardValue) return

    const row = this.currentNode(event)
    if (!row) return

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.focusRelativeNode(row, 1)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.focusRelativeNode(row, -1)
    } else if (event.key === "ArrowRight") {
      event.preventDefault()
      this.activateToggle(row, "show")
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.activateToggle(row, "hide")
    } else if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.activateToggle(row)
    }
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

  prepareKeyboardNavigation() {
    if (!this.element.hasAttribute("tabindex")) this.element.tabIndex = 0
    this.nodeTargets.forEach((node) => {
      if (!node.hasAttribute("tabindex")) node.tabIndex = -1
    })
  }

  currentNode(event) {
    const target = event.target
    if (target && target.closest) {
      const row = target.closest("[data-tree-view-state-target~='node']")
      if (row) return row
    }

    return this.visibleNodes()[0] || null
  }

  visibleNodes() {
    return this.nodeTargets.filter((node) => node.offsetParent !== null)
  }

  focusRelativeNode(row, offset) {
    const nodes = this.visibleNodes()
    const index = nodes.indexOf(row)
    if (index === -1) return

    const next = nodes[index + offset]
    if (next) next.focus()
  }

  activateToggle(row, preferredAction = null) {
    const showButton = row.querySelector(".show-button")
    const hideButton = row.querySelector(".remove-button")
    const button = preferredAction === "show" ? showButton : preferredAction === "hide" ? hideButton : showButton || hideButton
    if (button) button.click()
  }
}

export class TreeViewSelectionController extends Controller {
  static values = {
    cascade: Boolean,
    indeterminate: Boolean,
    maxCount: Number
  }

  connect() {
    this.updateIndeterminateStates()
    this.dispatchSelectionChanged()
  }

  selectedPayloads() {
    return this.selectedCheckboxes()
      .map((checkbox) => this.parsePayload(checkbox))
      .filter((payload) => payload !== null)
  }

  selectedValues() {
    return this.selectedCheckboxes().map((checkbox) => checkbox.value)
  }

  selectionDetail() {
    const selectedCheckboxes = this.selectedCheckboxes()
    return {
      selectedCount: selectedCheckboxes.length,
      selectedValues: selectedCheckboxes.map((checkbox) => checkbox.value),
      selectedPayloads: selectedCheckboxes
        .map((checkbox) => this.parsePayload(checkbox))
        .filter((payload) => payload !== null)
    }
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
    this.dispatchSelectionChanged()
  }

  dispatchSelectionChanged() {
    this.dispatch("change", {
      detail: this.selectionDetail()
    })
  }

  toggle(event) {
    const checkbox = event.target
    if (!checkbox || !checkbox.matches || !checkbox.matches(".tree-selection-checkbox")) return

    const wasChecked = checkbox.checked
    if (this.cascadeValue) this.setDescendantChecked(checkbox, checkbox.checked)
    this.enforceMaxCount(checkbox, wasChecked)
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

  enforceMaxCount(checkbox, attemptedChecked) {
    if (!this.hasMaxCountValue || this.maxCountValue <= 0) return

    const attemptedCount = this.selectedCheckboxes().length
    if (attemptedCount <= this.maxCountValue) return

    checkbox.checked = false
    checkbox.indeterminate = false
    if (this.cascadeValue) this.setDescendantChecked(checkbox, false)

    this.dispatch("limit-exceeded", {
      detail: {
        maxCount: this.maxCountValue,
        attemptedCount,
        attemptedChecked,
        checkbox
      }
    })
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

export class TreeViewTransferController extends Controller {
  start(event) {
    const row = this.rowFromEvent(event)
    if (!row) return

    const payload = this.payloadFromRow(row)
    if (event.dataTransfer && payload) event.dataTransfer.setData("application/json", JSON.stringify(payload))

    this.dispatch("started", { detail: { payload, row } })
  }

  over(event) {
    event.preventDefault()
    const row = this.rowFromEvent(event)
    this.dispatch("over", { detail: { payload: this.payloadFromRow(row), row } })
  }

  drop(event) {
    event.preventDefault()
    const targetRow = this.rowFromEvent(event)
    const sourcePayload = this.payloadFromEvent(event)
    const targetPayload = this.payloadFromRow(targetRow)

    this.dispatch("dropped", {
      detail: {
        source: sourcePayload,
        target: targetPayload,
        targetRow
      }
    })
  }

  rowFromEvent(event) {
    const target = event.target
    if (!target || !target.closest) return null

    return target.closest("tr[data-tree-depth]")
  }

  payloadFromRow(row) {
    if (!row || !row.dataset.treeTransferPayload) return null

    try {
      return JSON.parse(row.dataset.treeTransferPayload)
    } catch (_error) {
      this.dispatch("invalid-payload", { detail: { value: row.dataset.treeTransferPayload, row } })
      return null
    }
  }

  payloadFromEvent(event) {
    if (!event.dataTransfer) return null

    const value = event.dataTransfer.getData("application/json")
    if (!value) return null

    try {
      return JSON.parse(value)
    } catch (_error) {
      this.dispatch("invalid-transfer", { detail: { value } })
      return null
    }
  }
}

export function registerTreeViewControllers(application) {
  application.register("tree-view-state", TreeViewStateController)
  application.register("tree-view-selection", TreeViewSelectionController)
  application.register("tree-view-transfer", TreeViewTransferController)
}
