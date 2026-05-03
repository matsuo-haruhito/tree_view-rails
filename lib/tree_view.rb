# frozen_string_literal: true

require "tree_view/version"
require "tree_view/configuration"
require "tree_view/graph_adapter"
require "tree_view/render_state"
require "tree_view/toggle_scope"
require "tree_view/traversal"
require "tree_view/tree"
require "tree_view/node_key_validation"
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
  end
end

require "tree_view/engine" if defined?(Rails::Engine)
