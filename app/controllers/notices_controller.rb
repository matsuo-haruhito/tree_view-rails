# frozen_string_literal: true

class NoticesController < BaseController
  def index
    @notices = Notice
      .published
      .search(params)
      .order(publish_start_datetime: :desc)
      .page(params[:page])
      .per(Notice::PER_PAGE)
  end
end
