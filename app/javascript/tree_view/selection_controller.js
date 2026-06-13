import { Controller } from "@hotwired/stimulus"

export class TreeViewSelectionController extends Controller {
  static targets = ["selectedCount"]

  static values = {
    cascade: Boolean,
    indeterminate: Boolean,
    maxCount: Number,
    hiddenInputName: String
  }

  connect() {
    this.hiddenInputSyncedForm = null
    this.updateIndeterminateStates()
    this.dispatchSelectionChanged()
  }

  disconnect() {
    if (!this.hiddenInputSyncEnabled()) return

    const form = this.hiddenInputSyncedForm || this.hiddenInputForm()
    if (!form) return

    this.removeSyncedHiddenInputs(form)
    this.hiddenInputSyncedForm = null
  }

  selectedPayloads() {
    return this.selectedCheckboxes()
      .map((checkbox) => this.parsePayload(checkbox))
      .filter((payload) => payload !== null)
  }

  selectedValues() {
    return this.selectedCheckboxes().map((checkbox) => checkbox.value)
  }

  selectionDetail({ sourceCheckbox = null, attemptedChecked = null } = {}) {
    const selectedCheckboxes = this.selectedCheckboxes()
    return {
      selectedCount: selectedCheckboxes.length,
      selectedValues: selectedCheckboxes.map((checkbox) => checkbox.value),
      selectedPayloads: selectedCheckboxes
        .map((checkbox) => this.parsePayload(checkbox))
        .filter((payload) => payload !== null),
      sourceCheckbox,
      attemptedChecked
    }
  }

  submit(event) {
    if (event) event.preventDefault()

    const payloads = this.selectedPayloads()
    this.syncHiddenInputs(payloads)

    this.dispatch("selected", {
      detail: {
        payloads
      }
    })
  }

  refresh(detail = null) {
    this.updateIndeterminateStates()

    const selectionDetail = detail || this.selectionDetail()
    this.syncHiddenInputs(selectionDetail.selectedPayloads)

    this.dispatch("selected", {
      detail: {
        payloads: selectionDetail.selectedPayloads
      }
    })
    this.dispatchSelectionChanged(selectionDetail)
  }

  dispatchSelectionChanged(detail = this.selectionDetail()) {
    this.syncHiddenInputs(detail.selectedPayloads)
    this.syncSelectedCountTargets(detail.selectedCount)

    this.dispatch("change", {
      detail
    })
  }

  toggle(event) {
    const checkbox = event.target
    if (!checkbox || !checkbox.matches || !checkbox.matches(".tree-selection-checkbox")) return

    const attemptedChecked = checkbox.checked
    if (this.cascadeValue) this.setDescendantChecked(checkbox, checkbox.checked)
    this.enforceMaxCount(checkbox, attemptedChecked)
    this.updateIndeterminateStates()
    this.refresh(this.selectionDetail({ sourceCheckbox: checkbox, attemptedChecked }))
  }

  selectedCheckboxes() {
    return Array.from(
      this.element.querySelectorAll(".tree-selection-checkbox:checked:not(:disabled)")
    )
  }

  syncSelectedCountTargets(count) {
    if (!this.hasSelectedCountTarget) return

    this.selectedCountTargets.forEach((target) => {
      target.textContent = String(count)
    })
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

  syncHiddenInputs(payloads = this.selectedPayloads()) {
    if (!this.hiddenInputSyncEnabled()) return

    const form = this.hiddenInputForm()
    if (!form) return

    this.hiddenInputSyncedForm = form
    this.removeSyncedHiddenInputs(form)

    payloads.forEach((payload) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = this.hiddenInputNameValue
      input.value = JSON.stringify(payload)
      input.dataset.treeViewSelectionGeneratedHiddenInput = "true"
      input.dataset.treeViewSelectionSourceId = this.hiddenInputSourceId()
      form.appendChild(input)
    })
  }

  hiddenInputSyncEnabled() {
    return this.hasHiddenInputNameValue && this.hiddenInputNameValue.length > 0
  }

  hiddenInputForm() {
    return this.element.closest("form")
  }

  hiddenInputSourceId() {
    if (!this.element.dataset.treeViewSelectionSourceId) {
      this.element.dataset.treeViewSelectionSourceId = `tree-view-selection-${Math.random().toString(36).slice(2, 10)}`
    }

    return this.element.dataset.treeViewSelectionSourceId
  }

  removeSyncedHiddenInputs(form) {
    const sourceId = this.hiddenInputSourceId()

    form
      .querySelectorAll("[data-tree-view-selection-generated-hidden-input=\"true\"]")
      .forEach((input) => {
        if (input.dataset.treeViewSelectionSourceId === sourceId) input.remove()
      })
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
