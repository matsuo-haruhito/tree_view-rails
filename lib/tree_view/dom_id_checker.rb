# Safe implementation of DOM ID collision detection for TreeView nodes
# This class checks for duplicate DOM IDs in a tree of nodes.
module TreeView
  class DomIdChecker
    def self.duplicates(nodes)
      seen = {}
      duplicates = []
      nodes.each do |node|
        id = node.dom_id
        if seen.key?(id)
          duplicates << id
        else
          seen[id] = true
        end
      end
      duplicates
    end
  end
end