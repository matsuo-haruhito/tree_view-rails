# frozen_string_literal: true

module TreeViewBreadcrumbHelper
  DEFAULT_BREADCRUMB_CLASSES = {
    nav: "tree-view-breadcrumb",
    list: "tree-view-breadcrumb__list",
    item: "tree-view-breadcrumb__item",
    link: "tree-view-breadcrumb__link",
    current: "tree-view-breadcrumb__current",
    separator: "tree-view-breadcrumb__separator"
  }.freeze

  def tree_view_breadcrumb(tree,
                           item,
                           label_builder:,
                           path_builder: nil,
                           separator: "›",
                           nav_class: DEFAULT_BREADCRUMB_CLASSES[:nav],
                           list_class: DEFAULT_BREADCRUMB_CLASSES[:list],
                           item_class: DEFAULT_BREADCRUMB_CLASSES[:item],
                           link_class: DEFAULT_BREADCRUMB_CLASSES[:link],
                           current_class: DEFAULT_BREADCRUMB_CLASSES[:current],
                           separator_class: DEFAULT_BREADCRUMB_CLASSES[:separator],
                           aria_label: "Breadcrumb")
    validate_tree_view_breadcrumb_builder!(label_builder, :label_builder)
    validate_tree_view_breadcrumb_builder!(path_builder, :path_builder) if path_builder

    path_items = tree.path_for(item)
    list_items = path_items.each_with_index.map do |path_item, index|
      current = index == path_items.length - 1
      tag.li(class: item_class) do
        content = current || path_builder.nil? ?
          tree_view_breadcrumb_current_label(path_item, label_builder, current_class) :
          tree_view_breadcrumb_link(path_item, label_builder, path_builder, link_class)

        if current || separator.nil?
          content
        else
          safe_join([
            content,
            tag.span(separator, class: separator_class, aria: { hidden: true })
          ], " ")
        end
      end
    end

    tag.nav(class: nav_class, aria: { label: aria_label }) do
      tag.ol(safe_join(list_items), class: list_class)
    end
  end

  private

  def tree_view_breadcrumb_link(item, label_builder, path_builder, link_class)
    tag.a(label_builder.call(item), href: path_builder.call(item), class: link_class)
  end

  def tree_view_breadcrumb_current_label(item, label_builder, current_class)
    tag.span(label_builder.call(item), class: current_class, aria: { current: "page" })
  end

  def validate_tree_view_breadcrumb_builder!(builder, name)
    return if builder.respond_to?(:call)

    raise ArgumentError, "#{name} must respond to call"
  end
end

TreeViewHelper.include(TreeViewBreadcrumbHelper) if defined?(TreeViewHelper)
