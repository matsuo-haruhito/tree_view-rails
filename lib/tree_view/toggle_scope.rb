# frozen_string_literal: true

module TreeView
  class ToggleScope
    attr_reader :mode, :current_depth, :max_depth_from_root

    def initialize(mode:, current_depth:, max_depth_from_root: nil)
      @mode = mode.to_sym
      @current_depth = current_depth
      @max_depth_from_root = max_depth_from_root
    end

    def toggle_depth
      return current_depth if max_depth_from_root.nil?
      return max_depth_from_root if current_depth < max_depth_from_root

      current_depth
    end

    def within_scope?
      return false if max_depth_from_root.nil?

      current_depth < max_depth_from_root
    end
  end
end
