# frozen_string_literal: true

class Part < ApplicationRecord
  belongs_to :machine, optional: true, inverse_of: :parts
  belongs_to :unit, optional: true, inverse_of: :parts

  has_many :materials, dependent: :destroy

  validates :name, presence: true
  validate :machine_or_unit_is_present

  after_commit :broadcast_machines_tree_refresh

  private

  def machine_or_unit_is_present
    return if machine_id.present? || unit_id.present?

    errors.add(:base, 'machine または unit のいずれかが必要です')
  end

  def broadcast_machines_tree_refresh
    broadcast_refresh_later_to('machines')
  end
end
