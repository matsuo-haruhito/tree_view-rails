class ItemsController < ApplicationController

  def new
  end

  # 親アイテム取ってくるだけ。
  def index
    items = Item.select(:id, :parent_item_id, :name, :comment).to_a
    @items_by_parent_id = items.group_by(&:parent_item_id)
    @descendant_counts = Item.descendant_counts(@items_by_parent_id)
    @root_items = (@items_by_parent_id[nil] || []).sort_by { |item| @descendant_counts[item.id] }
  end

  # TurboStreamをキックする。
  def show_descendants
    @item = Item.find(params[:id])
    @children = @item.children
  end

  # TurboStreamをキックする。
  def remove_descendants
    @item = Item.find(params[:id])
    @descendant_ids = @item.descendant_ids
    @descendant_count = @descendant_ids.size
  end
end
