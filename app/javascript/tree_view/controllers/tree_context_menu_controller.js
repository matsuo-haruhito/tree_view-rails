import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "title", "collapseChildrenLink", "collapseGrandchildrenLink"]

  open(event) {
    const row = event.target.closest("[data-tree-context-row]")
    if (!row) return

    const childrenAction = this.resolveAction(row, "children")
    const grandchildrenAction = this.resolveAction(row, "grandchildren")
    const childrenPath = childrenAction?.path
    const grandchildrenPath = grandchildrenAction?.path
    if (!childrenPath && !grandchildrenPath) return

    event.preventDefault()

    this.titleTarget.textContent = row.dataset.treeContextLabel || "ノード操作"
    this.configureLink(this.collapseChildrenLinkTarget, childrenPath)
    this.collapseChildrenLinkTarget.textContent = childrenAction?.label || "子ノードを畳む"
    this.configureLink(this.collapseGrandchildrenLinkTarget, grandchildrenPath)
    this.collapseGrandchildrenLinkTarget.textContent = grandchildrenAction?.label || "孫ノードを畳む"
    this.positionMenu(event.clientX, event.clientY)
    this.menuTarget.classList.remove("d-none")
    this.menuTarget.setAttribute("aria-hidden", "false")
  }

  close(event) {
    if (this.menuTarget.classList.contains("d-none")) return
    if (event?.type === "click" && this.menuTarget.contains(event.target)) {
      this.hideMenu()
      return
    }
    if (event?.type === "click" && event.target.closest("[data-tree-context-row]")) return

    this.hideMenu()
  }

  configureLink(link, path) {
    if (path) {
      link.href = path
      link.classList.remove("d-none")
      link.setAttribute("aria-disabled", "false")
    } else {
      link.href = "#"
      link.classList.add("d-none")
      link.setAttribute("aria-disabled", "true")
    }
  }

  resolveAction(row, scope) {
    const state = this.scopeState(row, scope)
    if (state.available === false) return null

    if (state.hidden) {
      return {
        path: row.dataset[`treeContext${this.capitalize(scope)}ShowPath`],
        label: `${scope === "children" ? "子" : "孫"}ノードを開く`
      }
    }

    return {
      path: row.dataset[`treeContext${this.capitalize(scope)}HidePath`],
      label: `${scope === "children" ? "子" : "孫"}ノードを畳む`
    }
  }

  scopeState(row, scope) {
    const currentDepth = Number(row.dataset.treeDepth || 0)
    const subtreeRows = this.subtreeRows(row, currentDepth)
    const threshold = scope === "children" ? currentDepth + 2 : currentDepth + 3
    const prerequisiteDepth = scope === "children" ? currentDepth + 1 : currentDepth + 2
    const available = subtreeRows.some((candidate) => Number(candidate.dataset.treeDepth) === prerequisiteDepth)
    const visible = subtreeRows.some((candidate) => Number(candidate.dataset.treeDepth) >= threshold)

    return { available, hidden: !visible }
  }

  subtreeRows(row, currentDepth) {
    const rows = []
    let cursor = row.nextElementSibling

    while (cursor?.matches("[data-tree-context-row]")) {
      const depth = Number(cursor.dataset.treeDepth || 0)
      if (depth <= currentDepth) break
      rows.push(cursor)
      cursor = cursor.nextElementSibling
    }

    return rows
  }

  capitalize(text) {
    return text.charAt(0).toUpperCase() + text.slice(1)
  }

  positionMenu(x, y) {
    const menu = this.menuTarget
    menu.style.left = `${x}px`
    menu.style.top = `${y}px`

    requestAnimationFrame(() => {
      const rect = menu.getBoundingClientRect()
      const left = Math.min(x, window.innerWidth - rect.width - 12)
      const top = Math.min(y, window.innerHeight - rect.height - 12)
      menu.style.left = `${Math.max(12, left)}px`
      menu.style.top = `${Math.max(12, top)}px`
    })
  }

  hideMenu() {
    this.menuTarget.classList.add("d-none")
    this.menuTarget.setAttribute("aria-hidden", "true")
  }
}
