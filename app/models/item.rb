# app/models/item.rb

class Item < ApplicationRecord
  belongs_to :parent, class_name: 'Item', optional: true, foreign_key: 'parent_item_id'
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id'

  def descendants # 子孫って意味の単語らしい。
    children.preload(:children).flat_map { |child| [child] + child.descendants }
  end

 # PER_PAGE = 10 やろうと思ったけどやめた
end
