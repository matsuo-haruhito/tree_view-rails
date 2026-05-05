module TreeViewHelper
  module Rendering
    def tree_view_rows(render_state, mode: nil, collapsed: nil, window: nil)
      previous_tree_ui = @tree_ui
      @tree_ui = render_state.ui_config
      clear_tree_view_render_caches!
      render_context = TreeView::RenderContext.new(render_state: render_state, mode: mode, collapsed: collapsed)

      if window
        return tree_view_window_rows(render_context, window)
      end

      if render_context.root_items.empty? && render_state.empty_message.present?
        return render(partial: "tree_view/tree_empty_row", locals: {empty_message: render_state.empty_message})
      end

      render(
        partial: "tree_view/tree_row",
        collection: render_context.root_items,
        as: :item,
        locals: {render_context: render_context}
      )
    ensure
      clear_tree_view_render_caches!
      @tree_ui = previous_tree_ui
    end

    def tree_view_window(render_state, offset:, limit:)
      visible_rows = TreeView::VisibleRows.new(
        tree: render_state.tree,
        root_items: render_state.root_items,
        render_state: render_state
      )

      TreeView::RenderWindow.new(visible_rows, offset: offset, limit: limit)
    end

    private

    def tree_view_window_rows(render_context, window_options)
      window = if window_options.is_a?(TreeView::RenderWindow)
        window_options
      elsif window_options.respond_to?(:to_h)
        options = window_options.to_h.transform_keys(&:to_sym)
        tree_view_window(render_context.render_state, offset: options.fetch(:offset), limit: options.fetch(:limit))
      else
        raise ArgumentError, "window must be a TreeView::RenderWindow or Hash-like object"
      end

      return render(partial: "tree_view/tree_empty_row", locals: {empty_message: render_context.render_state.empty_message}) if window.empty? && render_context.render_state.empty_message.present?

      render(
        partial: "tree_view/tree_window_row",
        collection: window.rows,
        as: :visible_row,
        locals: {render_context: render_context}
      )
    end

    def clear_tree_view_render_caches!
      @tree_render_traversals = {}
    end
  end
end
