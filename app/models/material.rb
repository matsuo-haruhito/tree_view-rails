# frozen_string_literal: true

class Material < ApplicationRecord
  belongs_to :part, inverse_of: :materials

  validates :name, presence: true

  after_commit :broadcast_machines_tree_refresh

  private

  def broadcast_machines_tree_refresh
    broadcast_refresh_later_to('machines')
  end
end
