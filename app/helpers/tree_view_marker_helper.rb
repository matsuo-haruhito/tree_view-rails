module TreeViewMarkerHelper
  def tree_node_marker(item, builder = nil)
    value = builder&.call(item)
    return nil if value.nil?

    if value.respond_to?(:to_h)
      marker = value.to_h.symbolize_keys
      text = marker[:name] || marker[:text] || marker[:label]
      return nil if text.blank?

      {
        text: text,
        class: Array(marker[:class]).flatten.compact_blank,
        title: marker[:title],
        data: marker[:data].respond_to?(:to_h) ? marker[:data].to_h : {}
      }
    else
      {text: value, class: [], title: nil, data: {}}
    end
  end
end
