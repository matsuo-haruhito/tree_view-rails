# frozen_string_literal: true

class TreeViewState < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :view_key, presence: true
end
