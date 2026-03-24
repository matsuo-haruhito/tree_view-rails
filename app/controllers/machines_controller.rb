# frozen_string_literal: true

class MachinesController < ApplicationController
  DEFAULT_ROW_PARTIAL = 'machines/tree_columns'
  ROOTS_PER_PAGE = 10
  ALLOWED_NODE_TYPES = {
    'Machine' => Machine,
    'Unit' => Unit,
    'Part' => Part,
    'Material' => Material
  }.freeze

  def index
    render_state = build_render_state
    @tree = render_state.tree
    @root_page = Kaminari.paginate_array(render_state.root_items).page(params[:page]).per(ROOTS_PER_PAGE)
    @root_items = @root_page.to_a
    @row_partial = render_state.row_partial
    @tree_ui = render_state.ui_config
    @node_counts = node_counts
    @collapsed_all = params[:collapsed] == 'all'
  end

  def new
    @machine = Machine.new(parent_machine_id: params[:parent_machine_id])
  end

  def create
    @machine = Machine.new(machine_params)
    if @machine.save
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Machineを作成しました。' }
        format.turbo_stream { render_crud_success('Machineを作成しました。') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @machine = Machine.find(params[:id])
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.update(machine_params)
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Machineを更新しました。' }
        format.turbo_stream { render_crud_success('Machineを更新しました。') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    machine = Machine.find(params[:id])
    machine.destroy!
    respond_to do |format|
      format.html { redirect_to machines_path, notice: 'Machineを削除しました。' }
      format.turbo_stream { render_crud_success('Machineを削除しました。') }
    end
  end

  def show_descendants
    render_state = build_render_state
    @tree = render_state.tree
    @node = find_node!
    @children = @tree.children_for(@node)
    @row_partial = render_state.row_partial
    @tree_ui = render_state.ui_config
    @expand_scope = expand_scope
    @expanded_nodes = expanded_nodes_for_scope(@node, @tree, @expand_scope)
  end

  def remove_descendants
    render_state = build_render_state
    @tree = render_state.tree
    @node = find_node!
    @row_partial = render_state.row_partial
    @tree_ui = render_state.ui_config
    @collapse_scope = collapse_scope
    @descendants = collect_descendants(@node, min_depth: minimum_collapse_depth(@collapse_scope))
    @descendant_count = @descendants.size
    @collapsed_children = collapsed_children_for_scope(@node, @tree, @collapse_scope)
  end

  private

  def build_render_state
    graph_data = build_graph_data
    adapter = TreeView::GraphAdapter.new(
      roots: graph_data[:roots],
      children_resolver: graph_data[:children_resolver],
      node_key_resolver: method(:node_key)
    )
    tree = TreeView::Tree.new(adapter: adapter)
    TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: DEFAULT_ROW_PARTIAL,
      ui_config: build_ui_config
    )
  end

  def build_graph_data
    machines = Machine.order(:id).to_a
    units = Unit.order(:id).to_a
    parts = Part.order(:id).to_a
    materials = Material.order(:id).to_a

    child_machines_by_parent_id = machines.group_by(&:parent_machine_id)
    root_units_by_machine_id = units.select { |unit| unit.parent_unit_id.nil? }.group_by(&:machine_id)
    child_units_by_parent_id = units.group_by(&:parent_unit_id)
    machine_level_parts_by_machine_id = parts.select { |part| part.unit_id.nil? }.group_by(&:machine_id)
    unit_parts_by_unit_id = parts.group_by(&:unit_id)
    materials_by_part_id = materials.group_by(&:part_id)

    roots = machines.select { |machine| machine.parent_machine_id.nil? }
    children_resolver = lambda do |node|
      case node
      when Machine
        Array(child_machines_by_parent_id[node.id]) +
          Array(root_units_by_machine_id[node.id]) +
          Array(machine_level_parts_by_machine_id[node.id])
      when Unit
        Array(child_units_by_parent_id[node.id]) +
          Array(unit_parts_by_unit_id[node.id])
      when Part
        Array(materials_by_part_id[node.id])
      else
        []
      end
    end

    { roots: roots, children_resolver: children_resolver }
  end

  def build_ui_config
    TreeView::UiConfigBuilder.new(
      context: self,
      node_prefix: 'node',
      key_resolver: method(:node_dom_key)
    ).build(
      hide_descendants_path_builder: lambda do |node, display_depth, scope|
        remove_descendants_machines_path(
          node_type: node.class.name,
          node_id: node.id,
          depth: display_depth + 1,
          scope: scope,
          format: :turbo_stream
        )
      end,
      show_descendants_path_builder: lambda do |node, toggle_depth, scope|
        show_descendants_machines_path(
          node_type: node.class.name,
          node_id: node.id,
          depth: toggle_depth,
          scope: scope,
          format: :turbo_stream
        )
      end
    )
  end

  def find_node!
    model = ALLOWED_NODE_TYPES[params[:node_type]]
    raise ActiveRecord::RecordNotFound unless model

    model.find(params[:node_id])
  end

  def collect_descendants(node, min_depth: 1)
    descendants = []
    queue = @tree.children_for(node).map { |child| [child, 1] }
    seen = {}

    until queue.empty?
      current, depth = queue.shift
      node_key_value = node_key(current)
      next if seen[node_key_value]

      seen[node_key_value] = true
      descendants << current if depth >= min_depth
      queue.concat(@tree.children_for(current).map { |child| [child, depth + 1] })
    end

    descendants
  end

  def node_key(node)
    [node.class.name, node.id]
  end

  def node_dom_key(node_or_id)
    if node_or_id.respond_to?(:id)
      "#{node_or_id.class.name.underscore}_#{node_or_id.id}"
    else
      node_or_id
    end
  end

  def node_counts
    {
      machines: Machine.count,
      units: Unit.count,
      parts: Part.count,
      materials: Material.count
    }
  end

  def collapse_scope
    params[:scope].presence_in(%w[all children grandchildren]) || 'all'
  end

  def expand_scope
    params[:scope].presence_in(%w[all children grandchildren]) || 'all'
  end

  def minimum_collapse_depth(scope)
    case scope
    when 'children' then 2
    when 'grandchildren' then 3
    else 1
    end
  end

  def collapsed_children_for_scope(node, tree, scope)
    target_depth = case scope
                   when 'children' then 1
                   when 'grandchildren' then 2
                   end
    return [] unless target_depth

    collect_descendant_nodes_at_depth(node, tree, target_depth).filter_map do |descendant|
      hidden_count = tree.descendant_counts[tree.node_key_for(descendant)].to_i
      next if hidden_count.zero?

      { item: descendant, depth: params[:depth].to_i + target_depth, hidden_count: hidden_count }
    end
  end

  def collect_descendant_nodes_at_depth(node, tree, target_depth)
    queue = tree.children_for(node).map { |child| [child, 1] }
    nodes = []

    until queue.empty?
      current, depth = queue.shift
      nodes << current if depth == target_depth
      next if depth >= target_depth

      queue.concat(tree.children_for(current).map { |child| [child, depth + 1] })
    end

    nodes
  end

  def expanded_nodes_for_scope(node, tree, scope)
    target_depth = case scope
                   when 'children' then 1
                   when 'grandchildren' then 2
                   end
    return [] unless target_depth

    collect_descendant_nodes_at_depth(node, tree, target_depth).filter_map do |descendant|
      children = tree.children_for(descendant)
      next if children.empty?

      { item: descendant, depth: params[:depth].to_i + target_depth, children: children }
    end
  end

  def machine_params
    params.require(:machine).permit(:name, :parent_machine_id)
  end

  def render_crud_success(message)
    flash.now[:notice] = message
    render turbo_stream: [
      turbo_stream.update('flash_messages', partial: 'shared/flash_message'),
      turbo_stream.update('modal', '')
    ]
  end
end
