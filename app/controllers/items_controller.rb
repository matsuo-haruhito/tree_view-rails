class ItemsController < ApplicationController
  DEFAULT_ROW_PARTIAL = 'items/tree_columns'

  def new
    @item = Item.new(parent_item_id: params[:parent_item_id])
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      respond_to do |format|
        format.html { redirect_to items_path, notice: 'Itemを作成しました。' }
        format.turbo_stream { render_crud_success('Itemを作成しました。') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to items_path, notice: 'Itemを更新しました。' }
        format.turbo_stream { render_crud_success('Itemを更新しました。') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy!
    respond_to do |format|
      format.html { redirect_to items_path, notice: 'Itemを削除しました。' }
      format.turbo_stream { render_crud_success('Itemを削除しました。') }
    end
  end

  # 親アイテム取ってくるだけ。
  def index
    render_state = build_render_state
    @tree = render_state.tree
    @root_items = render_state.root_items
    @row_partial = render_state.row_partial
    @tree_ui = render_state.ui_config
    @node_counts = item_counts
  end

  # TurboStreamをキックする。
  def show_descendants
    @item = Item.find(params[:id])
    render_state = build_render_state
    @tree = render_state.tree
    @children = @tree.children_for(@item)
    @row_partial = render_state.row_partial
    @tree_ui = render_state.ui_config
    @expand_scope = expand_scope
    @expanded_nodes = expanded_nodes_for_scope(@item, @tree, @expand_scope)
  end

  # TurboStreamをキックする。
  def remove_descendants
    render_state = build_render_state
    @tree = render_state.tree
    @row_partial = render_state.row_partial
    @tree_ui = render_state.ui_config
    @item = Item.find(params[:id])
    @collapse_scope = collapse_scope
    child_ids_by_parent_id = TreeView::Traversal.child_ids_by_parent_id(Item.pluck(:id, :parent_item_id))
    @descendant_ids = descendant_ids_for_scope(@item.id, child_ids_by_parent_id, @collapse_scope)
    @descendant_count = @descendant_ids.size
    @collapsed_children = collapsed_children_for_scope(@item, @tree, @collapse_scope)
  end

  private

  def tree_records
    Item.select(:id, :parent_item_id, :name, :comment).to_a
  end

  def tree_row_partial
    DEFAULT_ROW_PARTIAL
  end

  def build_render_state
    tree = TreeView::Tree.new(records: tree_records, parent_id_method: :parent_item_id)
    ui_config = TreeView::UiConfigBuilder.new(context: self).build_for_items
    TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: tree_row_partial,
      ui_config: ui_config
    )
  end

  def item_counts
    parent_ids = Item.where.not(parent_item_id: nil).select(:parent_item_id)
    {
      total: Item.count,
      roots: Item.where(parent_item_id: nil).count,
      leaves: Item.where.not(id: parent_ids).count
    }
  end

  def collapse_scope
    params[:scope].presence_in(%w[all children grandchildren]) || 'all'
  end

  def expand_scope
    params[:scope].presence_in(%w[all children grandchildren]) || 'all'
  end

  def descendant_ids_for_scope(item_id, child_ids_by_parent_id, scope)
    case scope
    when 'children'
      TreeView::Traversal.descendant_ids(item_id, child_ids_by_parent_id, min_depth: 2)
    when 'grandchildren'
      TreeView::Traversal.descendant_ids(item_id, child_ids_by_parent_id, min_depth: 3)
    else
      TreeView::Traversal.descendant_ids(item_id, child_ids_by_parent_id)
    end
  end

  def collapsed_children_for_scope(item, tree, scope)
    target_depth = case scope
                   when 'children' then 1
                   when 'grandchildren' then 2
                   end
    return [] unless target_depth

    collect_descendant_nodes_at_depth(item, tree, target_depth).filter_map do |descendant|
      hidden_count = tree.descendant_counts[tree.node_key_for(descendant)].to_i
      next if hidden_count.zero?

      { item: descendant, depth: params[:depth].to_i + target_depth, hidden_count: hidden_count }
    end
  end

  def collect_descendant_nodes_at_depth(item, tree, target_depth)
    queue = tree.children_for(item).map { |child| [child, 1] }
    nodes = []

    until queue.empty?
      current, depth = queue.shift
      nodes << current if depth == target_depth
      next if depth >= target_depth

      queue.concat(tree.children_for(current).map { |child| [child, depth + 1] })
    end

    nodes
  end

  def expanded_nodes_for_scope(item, tree, scope)
    target_depth = case scope
                   when 'children' then 1
                   when 'grandchildren' then 2
                   end
    return [] unless target_depth

    collect_descendant_nodes_at_depth(item, tree, target_depth).filter_map do |descendant|
      children = tree.children_for(descendant)
      next if children.empty?

      { item: descendant, depth: params[:depth].to_i + target_depth, children: children }
    end
  end

  def item_params
    params.require(:item).permit(:name, :comment, :parent_item_id)
  end

  def render_crud_success(message)
    flash.now[:notice] = message
    render turbo_stream: [
      turbo_stream.update('flash_messages', partial: 'shared/flash_message'),
      turbo_stream.update('modal', '')
    ]
  end
end
