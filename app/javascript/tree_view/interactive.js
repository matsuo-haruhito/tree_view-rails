const TREE_VIEW_NATIVE_INTERACTIVE_SELECTOR = [
  "input",
  "textarea",
  "select",
  "button",
  "a",
  "[contenteditable]:not([contenteditable='false'])"
].join(", ")

const TREE_VIEW_INTERACTIVE_MARKER_SELECTOR = "[data-tree-view-interactive]"

const TREE_VIEW_BEHAVIOR_MARKER_SELECTORS = {
  keyboard: "[data-tree-view-ignore-keyboard]",
  rowClick: "[data-tree-view-ignore-row-click]",
  drag: "[data-tree-view-ignore-drag]"
}

export function isTreeViewInteractiveTarget(target, behavior = null, root = null) {
  if (!target || typeof target.closest !== "function") return false

  const selectors = [TREE_VIEW_NATIVE_INTERACTIVE_SELECTOR, TREE_VIEW_INTERACTIVE_MARKER_SELECTOR]
  if (behavior && TREE_VIEW_BEHAVIOR_MARKER_SELECTORS[behavior]) {
    selectors.push(TREE_VIEW_BEHAVIOR_MARKER_SELECTORS[behavior])
  }

  const interactiveElement = target.closest(selectors.join(", "))
  if (!interactiveElement) return false

  if (root && typeof root.contains === "function") {
    return root.contains(interactiveElement)
  }

  return true
}
