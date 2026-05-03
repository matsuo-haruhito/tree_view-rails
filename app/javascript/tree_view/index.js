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
    this.dispatch("selected", {
      detail: {
        payloads: this.selectedPayloads()
      }
    })
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
}

export function registerTreeViewControllers(application) {
  application.register("tree-view-state", TreeViewStateController)
  application.register("tree-view-selection", TreeViewSelectionController)
}
