class ItemsController < ApplicationController

  def new
  end

  # 親アイテム取ってくるだけ。
  def index
    @root_items = Item
      .includes(:children)
      .where(parent_item_id: nil)
  end

  # TurboStreamをキックする。
  def show_descendants
    @item = Item.find(params[:id])
    @children = @item.children
  end

  # TurboStreamをキックする。
  def remove_descendants
    @item = Item.find(params[:id])
    @children_id = @item.descendants.pluck(:id)
  end
end
