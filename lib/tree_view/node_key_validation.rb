# frozen_string_literal: true

module TreeView
  module NodeKeyValidation
    def initialize(*args, validate_node_keys: false, **kwargs, &block)
      super(*args, **kwargs, &block)
      validate_unique_node_keys! if validate_node_keys
    end
  end
end
