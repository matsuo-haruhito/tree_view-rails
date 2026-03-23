# frozen_string_literal: true

module TreeView
  class RenderState
    attr_reader :tree, :root_items, :row_partial, :ui_config

    def initialize(tree:, root_items:, row_partial:, ui_config:)
      @tree = tree
      @root_items = root_items
      @row_partial = row_partial
      @ui_config = ui_config
    end
  end
end
