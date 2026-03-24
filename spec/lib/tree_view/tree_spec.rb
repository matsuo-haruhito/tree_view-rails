require 'rails_helper'

RSpec.describe TreeView::Tree do
  CountryNode = Struct.new(:id, :name, :cities)
  CityNode = Struct.new(:id, :name, :recipes)
  RecipeNode = Struct.new(:id, :name, :steps)

  describe '#descendant_counts' do
    it 'ツリー内の各ノードに対する子孫数を返す' do
      root = create(:item, name: 'root')
      child1 = create(:item, parent_item_id: root.id, name: 'child1')
      child2 = create(:item, parent_item_id: root.id, name: 'child2')
      grandchild = create(:item, parent_item_id: child1.id, name: 'grandchild')

      tree = described_class.new(records: Item.all.to_a, parent_id_method: :parent_item_id)
      counts = tree.descendant_counts

      expect(counts[root.id]).to eq(3)
      expect(counts[child1.id]).to eq(1)
      expect(counts[child2.id]).to eq(0)
      expect(counts[grandchild.id]).to eq(0)
    end

    it 'children_resolverモードで異なるモデル間の親子を集計できる' do
      recipe_step = RecipeNode.new(2, 'step-1', [])
      recipe = RecipeNode.new(1, 'recipe-1', [recipe_step])
      city = CityNode.new(1, 'tokyo', [recipe])
      country = CountryNode.new(1, 'japan', [city])

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

    it 'graph adapterモードで異なるモデル間の親子を集計できる' do
      recipe_step = RecipeNode.new(2, 'step-1', [])
      recipe = RecipeNode.new(1, 'recipe-1', [recipe_step])
      city = CityNode.new(1, 'tokyo', [recipe])
      country = CountryNode.new(1, 'japan', [city])
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

  describe '#root_items' do
    it '子孫数でルートノードをソートする' do
      small_root = create(:item, name: 'small-root')
      large_root = create(:item, name: 'large-root')
      create(:item, parent_item_id: large_root.id, name: 'child')

      tree = described_class.new(records: Item.all.to_a, parent_id_method: :parent_item_id)

      expect(tree.root_items).to eq([small_root, large_root])
    end
  end

  describe '#node_key_for' do
    it 'children_resolverモードではクラス名とIDの組でキー衝突を避ける' do
      country = CountryNode.new(1, 'japan', [])
      city = CityNode.new(1, 'tokyo', [])
      tree = described_class.new(
        roots: [country],
        children_resolver: ->(node) { node.public_send(node.members.last) }
      )

      expect(tree.node_key_for(country)).not_to eq(tree.node_key_for(city))
    end
  end

  describe 'validation' do
    it 'adapterモードとrecordsモードの混在を禁止する' do
      adapter = TreeView::GraphAdapter.new(
        roots: [CountryNode.new(1, 'japan', [])],
        children_resolver: ->(node) { node.public_send(node.members.last) }
      )

      expect do
        described_class.new(adapter: adapter, records: [])
      end.to raise_error(ArgumentError, /adapter mode cannot be combined/)
    end
  end
end
