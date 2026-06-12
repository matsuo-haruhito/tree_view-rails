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
    aria_label: "Breadcrumb",
    html: {},
    list_html: {},
    item_html: {},
    link_html: {},
    current_html: {},
    separator_html: {})
    validate_tree_view_breadcrumb_builder!(label_builder, :label_builder)
    validate_tree_view_breadcrumb_builder!(path_builder, :path_builder) if path_builder

    path_items = tree.path_for(item)
    list_items = path_items.each_with_index.map do |path_item, index|
      current = index == path_items.length - 1
      tag.li(**tree_view_breadcrumb_html_options(item_html, path_item, option_name: :item_html, class_name: item_class)) do
        content = tree_view_breadcrumb_content(
          path_item,
          label_builder,
          path_builder,
          current,
          link_class,
          link_html,
          current_class,
          current_html
        )

        if current || separator.nil?
          content
        else
          safe_join([
            content,
            tag.span(
              separator,
              **tree_view_breadcrumb_html_options(
                separator_html,
                path_item,
                option_name: :separator_html,
                class_name: separator_class,
                aria: {hidden: true}
              )
            )
          ], " ")
        end
      end
    end

    tag.nav(**tree_view_breadcrumb_html_options(html, item, option_name: :html, class_name: nav_class, aria: {label: aria_label})) do
      tag.ol(safe_join(list_items), **tree_view_breadcrumb_html_options(list_html, item, option_name: :list_html, class_name: list_class))
    end
  end

  private

  def tree_view_breadcrumb_content(item, label_builder, path_builder, current, link_class, link_html, current_class, current_html)
    return tree_view_breadcrumb_current_label(item, label_builder, current_class, current_html) if current

    unless path_builder
      return tree_view_breadcrumb_plain_label(item, label_builder, current_class, current_html, :current_html)
    end

    href = path_builder.call(item)
    return tree_view_breadcrumb_link(item, label_builder, href, link_class, link_html) if href

    tree_view_breadcrumb_plain_label(item, label_builder, link_class, link_html, :link_html)
  end

  def tree_view_breadcrumb_link(item, label_builder, href, link_class, link_html)
    tag.a(
      label_builder.call(item),
      **tree_view_breadcrumb_html_options(
        link_html,
        item,
        option_name: :link_html,
        href: href,
        class_name: link_class
      )
    )
  end

  def tree_view_breadcrumb_plain_label(item, label_builder, label_class, label_html, option_name)
    tag.span(
      label_builder.call(item),
      **tree_view_breadcrumb_html_options(
        label_html,
        item,
        option_name: option_name,
        class_name: label_class
      )
    )
  end

  def tree_view_breadcrumb_current_label(item, label_builder, current_class, current_html)
    tag.span(
      label_builder.call(item),
      **tree_view_breadcrumb_html_options(
        current_html,
        item,
        option_name: :current_html,
        class_name: current_class,
        aria: {current: "page"}
      )
    )
  end

  def tree_view_breadcrumb_html_options(source, item, option_name:, class_name: nil, aria: {}, href: nil)
    options = tree_view_breadcrumb_resolve_html_options(source, item, option_name)
    options[:href] = href if href
    options[:class] = [class_name, options[:class]].compact if class_name
    options[:aria] = (options[:aria] || {}).merge(aria) if aria.any?
    options
  end

  def tree_view_breadcrumb_resolve_html_options(source, item, option_name)
    source = source.call(item) if source.respond_to?(:call)
    return {} if source.nil?

    unless source.respond_to?(:to_h)
      raise ArgumentError, "#{option_name} must be a Hash-like object or callable returning one"
    end

    source.to_h.deep_symbolize_keys
  end

  def validate_tree_view_breadcrumb_builder!(builder, name)
    return if builder.respond_to?(:call)

    raise ArgumentError, "#{name} must respond to call"
  end
end

TreeViewHelper.include(TreeViewBreadcrumbHelper) if defined?(TreeViewHelper)
