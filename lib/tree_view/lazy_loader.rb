module TreeView
  class LazyLoader
    # Implements on-demand child node fetching for TreeView
    # Safe format for GitHub API
    def initialize(fetch_callback)
      @fetch_callback = fetch_callback
      @loaded_nodes = {}
    end

    def load(node_id)
      return @loaded_nodes[node_id] if @loaded_nodes.key?(node_id)
      result = @fetch_callback.call(node_id)
      @loaded_nodes[node_id] = result
      result
    end
  end
end