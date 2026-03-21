class ItemsController < ApplicationController

  def new
  end

  # 親アイテム取ってくるだけ。
  def index
    snapshot = Item.tree_snapshot
    @items_by_parent_id = snapshot.items_by_parent_id
    @descendant_counts = snapshot.descendant_counts
    @root_items = snapshot.root_items
  end

  # TurboStreamをキックする。
  def show_descendants
    @item = Item.find(params[:id])
    snapshot = Item.tree_snapshot
    @items_by_parent_id = snapshot.items_by_parent_id
    @descendant_counts = snapshot.descendant_counts
    @children = @items_by_parent_id[@item.id] || []
  end

  # TurboStreamをキックする。
  def remove_descendants
    @item = Item.find(params[:id])
    @descendant_ids = @item.descendant_ids
    @descendant_count = @descendant_ids.size
  end
end
