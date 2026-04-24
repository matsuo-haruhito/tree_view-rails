require "spec_helper"

RSpec.describe TreeView::Traversal do
  describe ".child_ids_by_parent_id" do
    it "builds a parent to child id map" do
      pairs = [
        [1, nil],
        [2, 1],
        [3, 2]
      ]

      map = described_class.child_ids_by_parent_id(pairs)

      expect(map[nil]).to include(1)
      expect(map[1]).to include(2)
      expect(map[2]).to include(3)
    end
  end

  describe ".descendant_ids" do
    it "returns descendants recursively" do
      child_ids_by_parent_id = described_class.child_ids_by_parent_id([
        [1, nil],
        [2, 1],
        [3, 2]
      ])

      expect(described_class.descendant_ids(1, child_ids_by_parent_id)).to contain_exactly(2, 3)
      expect(described_class.descendant_ids(2, child_ids_by_parent_id)).to contain_exactly(3)
      expect(described_class.descendant_ids(3, child_ids_by_parent_id)).to eq([])
    end
  end
end
