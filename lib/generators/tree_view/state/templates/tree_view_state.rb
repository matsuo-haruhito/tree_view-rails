# frozen_string_literal: true

class TreeViewState < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :tree_instance_key, presence: true
end
