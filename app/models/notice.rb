# frozen_string_literal: true

class Notice < ApplicationRecord
  include SearchCop
  include ExtendOrder
  include BelongsToUser

  belongs_to_user prefix: :create
  belongs_to_user prefix: :update

  search_scope :keyword_search do
    attributes :title, :body
  end

  scope :search, lambda { |params|
    result = self

    result = result.keyword_search(params[:q]) if params[:q].present?

    result
  }

  scope :published, lambda {
    now = Time.current

    where('publish_start_datetime < ?', now)
      .where('? < publish_end_datetime OR publish_end_datetime IS NULL', now)
  }

  PER_PAGE = 10
end
