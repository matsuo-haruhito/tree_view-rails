require "json"

module TreeViewHelper
  module Transfer
    def tree_row_transfer_data(item, tree, builder = nil)
      return {} if builder.nil?

      payload = tree_row_event_payload(item, tree, builder)
      {
        tree_transfer_payload: JSON.generate(payload),
        tree_transfer_node_key: tree.node_key_for(item),
        action: [
          "dragstart->tree-view-transfer#start",
          "dragover->tree-view-transfer#over",
          "drop->tree-view-transfer#drop"
        ].join(" ")
      }
    end

    def tree_row_event_payload(item, tree, builder = nil)
      payload = builder ? builder.call(item) : default_tree_row_event_payload(item, tree)
      return payload.to_h if payload.respond_to?(:to_h)

      raise ArgumentError, "row_event_payload_builder must return a Hash-like object for #{tree_diagnostic_node_label(item, tree)}"
    end
  end
end
