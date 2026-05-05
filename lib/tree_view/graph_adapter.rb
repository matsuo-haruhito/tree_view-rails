# frozen_string_literal: true

module TreeView
  class GraphAdapter
    attr_reader :roots

    def initialize(roots:, children_resolver:, node_key_resolver: nil)
      @roots = Array(roots)
      @children_resolver = children_resolver
      @node_key_resolver = node_key_resolver

      raise ArgumentError, "roots must be provided" if @roots.empty?
      raise ArgumentError, "children_resolver must respond to call" unless @children_resolver.respond_to?(:call)
    end

    def children_for(node)
      Array(@children_resolver.call(node))
    end

    def node_key_for(node, id_method: :id)
      if @node_key_resolver
        @node_key_resolver.call(node)
      else
        [node.class.name, node.public_send(id_method)]
      end
    end
  end
end
