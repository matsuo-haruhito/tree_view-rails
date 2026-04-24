# frozen_string_literal: true

class Unit < ApplicationRecord
  belongs_to :machine, inverse_of: :units
  belongs_to :parent_unit, class_name: 'Unit', optional: true, inverse_of: :child_units

  has_many :child_units,
           class_name: 'Unit',
           foreign_key: :parent_unit_id,
           inverse_of: :parent_unit,
           dependent: :nullify
  has_many :parts, dependent: :destroy

  validates :name, presence: true

  after_commit :broadcast_machines_tree_refresh

  private

  def broadcast_machines_tree_refresh
    broadcast_refresh_later_to('machines')
  end
end
