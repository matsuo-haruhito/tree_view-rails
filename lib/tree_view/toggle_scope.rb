# frozen_string_literal: true

module TreeView
  class ToggleScope
    attr_reader :mode,
                :current_depth,
                :max_depth_from_root,
                :current_leaf_distance,
                :max_leaf_distance

    # mode is intentionally carried as request/path metadata.
    # The current expansion boundary is determined by depth and leaf distance,
    # while builders may still need the original mode value when constructing
    # URLs or params for host applications.
    def initialize(mode:, current_depth:, max_depth_from_root: nil, current_leaf_distance: nil, max_leaf_distance: nil)
      @mode = mode.to_sym
      @current_depth = current_depth
      @max_depth_from_root = max_depth_from_root
      @current_leaf_distance = current_leaf_distance
      @max_leaf_distance = max_leaf_distance
    end

    def toggle_depth
      return max_depth_from_root if root_depth_within_scope?

      current_depth
    end

    def toggle_leaf_distance
      return max_leaf_distance if leaf_distance_within_scope?

      current_leaf_distance
    end

    def within_scope?
      root_depth_within_scope? || leaf_distance_within_scope?
    end

    def root_depth_within_scope?
      return false if max_depth_from_root.nil?

      current_depth < max_depth_from_root
    end

    def leaf_distance_within_scope?
      return false if max_leaf_distance.nil? || current_leaf_distance.nil?

      current_leaf_distance < max_leaf_distance
    end
  end
end
