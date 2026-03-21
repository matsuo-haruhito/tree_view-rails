# app/models/item.rb

class Item < ApplicationRecord
  TreeSnapshot = Struct.new(:items_by_parent_id, :descendant_counts, :root_items, keyword_init: true)

  belongs_to :parent, class_name: 'Item', optional: true, foreign_key: 'parent_item_id'
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id'

  def self.tree_snapshot(items = nil)
    records = items || select(:id, :parent_item_id, :name, :comment).to_a
    items_by_parent_id = records.group_by(&:parent_item_id)
    counts = descendant_counts(items_by_parent_id)
    root_items = (items_by_parent_id[nil] || []).sort_by { |item| counts[item.id] }

    TreeSnapshot.new(
      items_by_parent_id: items_by_parent_id,
      descendant_counts: counts,
      root_items: root_items
    )
  end

  def self.descendant_counts(items_by_parent_id)
    memo = {}

    count_descendants = lambda do |item|
      return memo[item.id] if memo.key?(item.id)

      children = items_by_parent_id[item.id] || []
      memo[item.id] = children.sum { |child| 1 + count_descendants.call(child) }
    end

    items_by_parent_id.each_value do |items|
      items.each { |item| count_descendants.call(item) }
    end
    memo
  end

  def self.child_ids_by_parent_id
    pluck(:id, :parent_item_id).each_with_object({}) do |(item_id, parent_item_id), map|
      (map[parent_item_id] ||= []) << item_id
    end
  end

  def descendants # 子孫って意味の単語らしい。
    children.preload(:children).flat_map { |child| [child] + child.descendants }
  end

  def descendant_ids(child_ids_by_parent_id = nil)
    child_ids_by_parent_id ||= self.class.child_ids_by_parent_id

    descendant_ids = []
    stack = (child_ids_by_parent_id[id] || []).dup

    until stack.empty?
      child_id = stack.pop
      descendant_ids << child_id
      stack.concat(child_ids_by_parent_id[child_id] || [])
    end

    descendant_ids
  end

 # PER_PAGE = 10 やろうと思ったけどやめた
end
