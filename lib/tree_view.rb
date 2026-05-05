# frozen_string_literal: true

require "tree_view/version"
require "tree_view/configuration"
require "tree_view/graph_adapter"
require "tree_view/render_state"
require "tree_view/render_state_row_state"
require "tree_view/render_state_row_status"
require "tree_view/render_state_state_messages"
require "tree_view/render_state_lazy_loading"
require "tree_view/render_context"
require "tree_view/row_context"
require "tree_view/persisted_state"
require "tree_view/render_state_persisted_state"
require "tree_view/state_store"
require "tree_view/dom_id_validator"
require "tree_view/selection_params"
require "tree_view/toggle_scope"
require "tree_view/traversal"
require "tree_view/render_traversal"
require "tree_view/visible_rows"
require "tree_view/render_window"
require "tree_view/filtered_tree"
require "tree_view/tree"
require "tree_view/node_key_validation"
require "tree_view/cycle_diagnostics"
require "tree_view/sorters"
require "tree_view/path_tree"
require "tree_view/reverse_tree"
require "tree_view/ui_config"
require "tree_view/ui_config_builder"

TreeView::Tree.prepend(TreeView::NodeKeyValidation)

module TreeView
  class << self
    # GEM 利用側の全体既定値はここから設定する。
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def parse_selection_params(value)
      SelectionParams.parse(value)
    end

    def node_key(type, value)
      [type, value].map { |part| part.to_s.strip }.join(":")
    end
  end
end

require "tree_view/engine" if defined?(Rails::Engine)
