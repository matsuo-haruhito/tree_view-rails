module ItemsHelper
  include TreeViewHelper

  def item_node_key(item)
    "item:#{item.id}"
  end

  private

  def default_tree_ui
    @default_tree_ui ||= TreeView::UiConfigBuilder.new(context: self).build_for_items
  end
end
