import { Controller } from "@hotwired/stimulus"

export class TreeViewRemoteStateController extends Controller {
  loading(event) {
    this.applyState(event, "loading")
  }

  loaded(event) {
    this.applyState(event, "loaded", { loaded: true })
  }

  error(event) {
    this.applyState(event, "error")
  }

  retry(event) {
    const row = this.rowFromEvent(event)
    if (!row) return

    row.dataset.remoteState = "loading"
    this.dispatch("change", {
      detail: this.remoteStateDetail(row, "loading")
    })
    this.dispatch("retry", {
      detail: this.remoteStateDetail(row)
    })
  }

  applyState(event, state, options = {}) {
    const row = this.rowFromEvent(event)
    if (!row) return

    row.dataset.remoteState = state
    if (options.loaded) row.dataset.treeLoaded = "true"

    this.dispatch("change", {
      detail: this.remoteStateDetail(row, state)
    })
  }

  remoteStateDetail(row, state = null) {
    const detail = {
      row,
      childrenUrl: row.dataset.treeChildrenUrl || null,
      nodeKey: row.dataset.treeViewStateNodeKey || null
    }

    if (state) detail.state = state

    return detail
  }

  rowFromEvent(event) {
    if (event.detail && event.detail.row) return event.detail.row

    const target = event.target
    if (!target || !target.closest) return null

    return target.closest("[data-tree-view-state-target~='node']")
  }
}
