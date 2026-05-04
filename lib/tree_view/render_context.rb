# frozen_string_literal: true

module TreeView
  class RenderContext
    attr_reader :render_state, :mode

    def initialize(render_state:, mode: nil, collapsed: nil)
      @render_state = render_state
      @mode = mode
      @collapsed_override = collapsed
    end

    def tree
      render_state.tree
    end

    def root_items
      render_state.root_items
    end

    def row_partial
      render_state.row_partial
    end

    def row_actions_partial
      render_state.row_actions_partial
    end

    def collapsed?
      return @collapsed_override unless @collapsed_override.nil?

      render_state.effective_initial_state == :collapsed
    end

    def max_initial_depth
      render_state.max_initial_depth
    end

    def max_render_depth
      render_state.max_render_depth
    end

    def max_leaf_distance
      render_state.max_leaf_distance
    end

    def max_toggle_depth_from_root
      render_state.max_toggle_depth_from_root
    end

    def max_toggle_leaf_distance
      render_state.max_toggle_leaf_distance
    end

    def expanded_keys
      render_state.expanded_keys
    end

    def collapsed_keys
      render_state.collapsed_keys
    end

    def current_key
      render_state.current_key
    end

    def selection_enabled?
      render_state.selection_enabled?
    end

    def selection_visibility
      render_state.selection_visibility
    end

    def selection_payload_builder
      render_state.selection_payload_builder
    end

    def selection_checkbox_name
      render_state.selection_checkbox_name
    end

    def selection_disabled_builder
      render_state.selection_disabled_builder
    end

    def selection_disabled_reason_builder
      render_state.selection_disabled_reason_builder
    end

    def selection_selected_keys
      render_state.selection_selected_keys
    end

    def hidden_message_builder
      render_state.hidden_message_builder
    end

    def row_class_builder
      render_state.row_class_builder
    end

    def row_data_builder
      render_state.row_data_builder
    end

    def depth_label_builder
      render_state.depth_label_builder
    end

    def badge_builder
      render_state.badge_builder
    end
  end
end
