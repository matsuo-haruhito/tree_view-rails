# frozen_string_literal: true

module TreeView
  # Base class for public TreeView failures.
  #
  # TreeView keeps this as an ArgumentError subclass so host apps that already
  # rescue existing validation/configuration ArgumentError failures continue to
  # work while new integrations can rescue TreeView::Error explicitly.
  class Error < ArgumentError; end

  # Raised when TreeView configuration or option combinations are invalid.
  class ConfigurationError < Error; end

  # Raised when tree data cannot be treated as a valid tree.
  class InvalidTreeError < Error; end

  # Raised when multiple nodes resolve to the same node key.
  class DuplicateNodeKeyError < InvalidTreeError; end

  # Raised when TreeView detects a cycle while walking tree data.
  class CycleDetectedError < InvalidTreeError; end

  # Raised when render window offset/limit arguments are invalid.
  class InvalidRenderWindowError < Error; end
end
