# frozen_string_literal: true

class Machine < ApplicationRecord
  belongs_to :parent_machine, class_name: 'Machine', optional: true, inverse_of: :child_machines

  has_many :child_machines,
           class_name: 'Machine',
           foreign_key: :parent_machine_id,
           inverse_of: :parent_machine,
           dependent: :nullify
  has_many :units, dependent: :destroy
  has_many :root_units, -> { where(parent_unit_id: nil) }, class_name: 'Unit', inverse_of: :machine
  has_many :parts, dependent: :destroy
  has_many :machine_level_parts, -> { where(unit_id: nil) }, class_name: 'Part', inverse_of: :machine

  validates :name, presence: true

  after_commit :broadcast_machines_tree_refresh

  private

  def broadcast_machines_tree_refresh
    broadcast_refresh_later_to('machines')
  end
end
