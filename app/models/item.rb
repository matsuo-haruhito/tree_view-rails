# app/models/item.rb

class Item < ApplicationRecord
  belongs_to :parent, class_name: 'Item', optional: true, foreign_key: 'parent_item_id'
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id', dependent: :nullify

  after_commit :broadcast_items_tree_refresh

  def descendants # 子孫って意味の単語らしい。
    children.preload(:children).flat_map { |child| [child] + child.descendants }
  end

 # PER_PAGE = 10 やろうと思ったけどやめた

  private

  # Sample page only: the host app can subscribe to "items" and refresh the tree
  # without making Turbo broadcasting a TreeView core concern.
  def broadcast_items_tree_refresh
    broadcast_refresh_later_to('items')
  end
end
