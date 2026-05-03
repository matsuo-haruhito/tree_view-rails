# frozen_string_literal: true

module TreeViewRowAttrsHelper
  def tree_row_aria(item, tree, depth:, expanded:, selected: false)
    attrs = {
      level: depth.to_i + 1,
      selected: selected
    }
    attrs[:expanded] = expanded if tree.children_for(item).any?
    attrs
  end
end

TreeViewHelper.include(TreeViewRowAttrsHelper) if defined?(TreeViewHelper)
