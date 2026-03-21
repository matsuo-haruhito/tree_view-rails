module ItemsHelper
  def remove_descendants_link(item, display_depth, css_class: 'btn btn-danger remove-button')
    link_to(
      remove_descendants_item_path(item, depth: display_depth + 1, format: :turbo_stream),
      data: { turbo_stream: true },
      class: css_class
    ) { display_depth.to_s }
  end

  def show_descendants_link(item, request_depth, css_class: 'btn btn-primary show-button')
    display_depth = request_depth - 1
    link_to(
      show_descendants_item_path(item, depth: request_depth, format: :turbo_stream),
      data: { turbo_stream: true },
      class: css_class,
      id: "show_button_#{item.id}"
    ) { display_depth.to_s }
  end
end
