import TreeContextMenuController from "tree_view/controllers/tree_context_menu_controller"

export function registerTreeViewControllers(application) {
  application.register("tree-context-menu", TreeContextMenuController)
}

export { TreeContextMenuController }
