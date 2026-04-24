# frozen_string_literal: true

module MachinesHelper
  include ItemsHelper

  def machine_node_type_label(node)
    case node
    when Machine then '機械'
    when Unit then 'ユニット'
    when Part then '部品'
    when Material then '材料'
    else node.class.name
    end
  end

  def machine_node_key(node)
    "#{node.class.name.underscore}:#{node.id}"
  end

  def machine_parent_label(node)
    case node
    when Machine
      node.parent_machine_id ? "machine:#{node.parent_machine_id}" : '-'
    when Unit
      node.parent_unit_id ? "unit:#{node.parent_unit_id}" : "machine:#{node.machine_id}"
    when Part
      node.unit_id ? "unit:#{node.unit_id}" : "machine:#{node.machine_id}"
    when Material
      "part:#{node.part_id}"
    else
      '-'
    end
  end

  def machine_node_detail(node)
    case node
    when Machine
      '機械本体'
    when Unit
      "所属機械ID: #{node.machine_id}"
    when Part
      if node.unit_id
        "ユニットID: #{node.unit_id} / 機械ID: #{node.machine_id}"
      else
        "機械共通部品 / 機械ID: #{node.machine_id}"
      end
    when Material
      "部品ID: #{node.part_id}"
    else
      '-'
    end
  end

  def machine_children_count(node, tree = @tree)
    tree.children_for(node).size
  end

  def machine_descendant_count(node, tree = @tree)
    tree.descendant_counts[tree.node_key_for(node)].to_i
  end
end
