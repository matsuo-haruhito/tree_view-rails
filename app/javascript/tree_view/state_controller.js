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
