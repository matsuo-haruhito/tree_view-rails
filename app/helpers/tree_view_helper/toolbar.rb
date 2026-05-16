# frozen_string_literal: true

module TreeViewHelper
  module Toolbar
    DEFAULT_TREE_VIEW_TOOLBAR_ACTIONS = %i[expand_all collapse_all].freeze
    TREE_VIEW_TOOLBAR_ACTIONS = %i[expand_all collapse_all collapse_all_except_current_path].freeze
    TREE_VIEW_TOOLBAR_LABELS = {
      expand_all: "Expand all",
      collapse_all: "Collapse all",
      collapse_all_except_current_path: "Collapse all except current path"
    }.freeze
    TREE_VIEW_TOOLBAR_STATES = {
      expand_all: :expanded,
      collapse_all: :collapsed,
      collapse_all_except_current_path: :current_path
    }.freeze

    def tree_view_toolbar(render_state, actions: DEFAULT_TREE_VIEW_TOOLBAR_ACTIONS, labels: {}, class_name: "tree-view-toolbar", button_class_name: "tree-view-toolbar__button")
      normalized_actions = normalize_tree_view_toolbar_actions(actions)
      normalized_labels = labels.to_h.transform_keys(&:to_sym)

      content_tag(:div, class: class_name, data: {tree_view_toolbar: true}) do
        safe_join(
          normalized_actions.filter_map do |action|
            tree_view_toolbar_action(render_state, action, normalized_labels, button_class_name)
          end
        )
      end
    end

    private

    def normalize_tree_view_toolbar_actions(actions)
      Array(actions).map do |action|
        normalized_action = action.to_sym
        next normalized_action if TREE_VIEW_TOOLBAR_ACTIONS.include?(normalized_action)

        raise TreeView::ConfigurationError, "unknown tree_view_toolbar action: #{action}; supported actions are: #{TREE_VIEW_TOOLBAR_ACTIONS.join(", ")}"
      end
    end

    def tree_view_toolbar_action(render_state, action, labels, button_class_name)
      path = tree_view_toolbar_path(render_state, action)
      label = labels.fetch(action, TREE_VIEW_TOOLBAR_LABELS.fetch(action))
      data = {tree_view_toolbar_action: action}

      if path
        link_to(label, path, class: button_class_name, data: data)
      else
        button_tag(label, type: "button", class: button_class_name, disabled: true, data: data.merge(tree_view_toolbar_disabled: true))
      end
    end

    def tree_view_toolbar_path(render_state, action)
      return nil unless render_state.ui_config.respond_to?(:toggle_all_path)

      render_state.ui_config.toggle_all_path(state: TREE_VIEW_TOOLBAR_STATES.fetch(action))
    end
  end
end
