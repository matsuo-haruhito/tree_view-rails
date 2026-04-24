require "spec_helper"

RSpec.describe TreeView::Tree do
  ItemNode = Struct.new(:id, :parent_item_id, :name, keyword_init: true)
  CountryNode = Struct.new(:id, :name, :cities)
  CityNode = Struct.new(:id, :name, :recipes)
  RecipeNode = Struct.new(:id, :name, :steps)

  describe "#descendant_counts" do
    it "counts descendants in records mode" do
      root = ItemNode.new(id: 1, parent_item_id: nil, name: "root")
      child1 = ItemNode.new(id: 2, parent_item_id: 1, name: "child1")
      child2 = ItemNode.new(id: 3, parent_item_id: 1, name: "child2")
      grandchild = ItemNode.new(id: 4, parent_item_id: 2, name: "grandchild")

      tree = described_class.new(records: [root, child1, child2, grandchild], parent_id_method: :parent_item_id)
      counts = tree.descendant_counts

      expect(counts[root.id]).to eq(3)
      expect(counts[child1.id]).to eq(1)
      expect(counts[child2.id]).to eq(0)
      expect(counts[grandchild.id]).to eq(0)
    end

    it "counts descendants across heterogeneous nodes in resolver mode" do
      recipe_step = RecipeNode.new(2, "step-1", [])
      recipe = RecipeNode.new(1, "recipe-1", [recipe_step])
      city = CityNode.new(1, "tokyo", [recipe])
      country = CountryNode.new(1, "japan", [city])

      tree = described_class.new(
        roots: [country],
        children_resolver: ->(node) { node.public_send(node.members.last) }
      )

      counts = tree.descendant_counts
      expect(counts[tree.node_key_for(country)]).to eq(3)
      expect(counts[tree.node_key_for(city)]).to eq(2)
      expect(counts[tree.node_key_for(recipe)]).to eq(1)
      expect(counts[tree.node_key_for(recipe_step)]).to eq(0)
    end

    it "counts descendants in adapter mode" do
      recipe_step = RecipeNode.new(2, "step-1", [])
      recipe = RecipeNode.new(1, "recipe-1", [recipe_step])
      city = CityNode.new(1, "tokyo", [recipe])
      country = CountryNode.new(1, "japan", [city])
      adapter = TreeView::GraphAdapter.new(
        roots: [country],
        children_resolver: ->(node) { node.public_send(node.members.last) }
      )

      tree = described_class.new(adapter: adapter)
      counts = tree.descendant_counts

      expect(counts[tree.node_key_for(country)]).to eq(3)
      expect(counts[tree.node_key_for(city)]).to eq(2)
      expect(counts[tree.node_key_for(recipe)]).to eq(1)
      expect(counts[tree.node_key_for(recipe_step)]).to eq(0)
    end
  end

  describe "#root_items" do
    it "sorts roots by descendant counts" do
      small_root = ItemNode.new(id: 1, parent_item_id: nil, name: "small-root")
      large_root = ItemNode.new(id: 2, parent_item_id: nil, name: "large-root")
      child = ItemNode.new(id: 3, parent_item_id: 2, name: "child")

      tree = described_class.new(records: [small_root, large_root, child], parent_id_method: :parent_item_id)

      expect(tree.root_items).to eq([small_root, large_root])
    end
  end

  describe "#node_key_for" do
    it "avoids collisions in resolver mode" do
      country = CountryNode.new(1, "japan", [])
      city = CityNode.new(1, "tokyo", [])
      tree = described_class.new(
        roots: [country],
        children_resolver: ->(node) { node.public_send(node.members.last) }
      )

      expect(tree.node_key_for(country)).not_to eq(tree.node_key_for(city))
    end
  end

  describe "validation" do
    it "rejects mixing adapter mode with records mode" do
      adapter = TreeView::GraphAdapter.new(
        roots: [CountryNode.new(1, "japan", [])],
        children_resolver: ->(node) { node.public_send(node.members.last) }
      )

      expect do
        described_class.new(adapter: adapter, records: [])
      end.to raise_error(ArgumentError, /adapter mode cannot be combined/)
    end
  end
end
