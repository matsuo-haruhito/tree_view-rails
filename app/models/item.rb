# app/models/item.rb

class Item < ApplicationRecord
  belongs_to :parent, class_name: 'Item', optional: true, foreign_key: 'parent_item_id'
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id'

  def self.descendant_counts(items_by_parent_id)
    memo = {}

    count_descendants = lambda do |item_id|
      return memo[item_id] if memo.key?(item_id)

      children = items_by_parent_id[item_id] || []
      memo[item_id] = children.sum { |child| 1 + count_descendants.call(child.id) }
    end

    items_by_parent_id.each_value do |items|
      items.each { |item| count_descendants.call(item.id) }
    end
    memo
  end

  def self.child_ids_by_parent_id
    pluck(:id, :parent_item_id).each_with_object(Hash.new { |h, key| h[key] = [] }) do |(item_id, parent_item_id), map|
      map[parent_item_id] << item_id
    end
  end

  def descendants # 子孫って意味の単語らしい。
    children.preload(:children).flat_map { |child| [child] + child.descendants }
  end

  def descendant_ids(child_ids_by_parent_id = nil)
    child_ids_by_parent_id ||= self.class.child_ids_by_parent_id

    descendant_ids = []
    stack = (child_ids_by_parent_id[id.to_s] || []).dup

    until stack.empty?
      child_id = stack.pop
      descendant_ids << child_id
      stack.concat(child_ids_by_parent_id[child_id.to_s] || [])
    end

    descendant_ids
  end

 # PER_PAGE = 10 やろうと思ったけどやめた
end
