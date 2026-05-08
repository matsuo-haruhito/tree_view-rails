import { Controller } from "@hotwired/stimulus"

export class TreeViewClientController extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const row = this.rowForButton(button)
    if (!row) return

    const nextExpanded = !this.expanded(row)
    this.setExpanded(row, button, nextExpanded)
    this.refreshRows()
  }

  connect() {
    this.refreshRows()
  }

  rowForButton(button) {
    const key = button.dataset.treeViewClientNodeKey
    if (!key) return button.closest("[data-tree-view-client-node-key]")

    return this.rows().find((row) => row.dataset.treeViewClientNodeKey === key)
  }

  rows() {
    return Array.from(this.element.querySelectorAll("[data-tree-view-client-node-key]"))
  }

  expanded(row) {
    return row.dataset.treeViewClientExpanded === "true"
  }

  setExpanded(row, button, expanded) {
    const value = expanded ? "true" : "false"
    row.dataset.treeViewClientExpanded = value
    row.dataset.treeViewStateExpanded = value
    row.setAttribute("aria-expanded", value)
    if (button) button.setAttribute("aria-expanded", value)
    this.setHiddenCountVisible(row.dataset.treeViewClientNodeKey, !expanded)
  }

  setHiddenCountVisible(nodeKey, visible) {
    if (!nodeKey) return

    this.element
      .querySelectorAll(`[data-tree-view-client-hidden-count-for="${CSS.escape(nodeKey)}"]`)
      .forEach((element) => {
        element.hidden = !visible
      })
  }

  refreshRows() {
    const collapsedDepths = []

    this.rows().forEach((row) => {
      const depth = Number.parseInt(row.dataset.treeViewClientDepth || "0", 10)

      while (collapsedDepths.length > 0 && collapsedDepths[collapsedDepths.length - 1] >= depth) {
        collapsedDepths.pop()
      }

      const hiddenByAncestor = collapsedDepths.length > 0
      row.hidden = hiddenByAncestor
      this.setHiddenCountVisible(row.dataset.treeViewClientNodeKey, !this.expanded(row))

      if (!this.expanded(row)) {
        collapsedDepths.push(depth)
      }
    })
  }
}
