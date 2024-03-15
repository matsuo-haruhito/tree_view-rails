# frozen_string_literal: true

module PaginationHelper
  def page_entries_info(page)
    render 'kaminari/page_entries_info', page: page
  end

  def render_with_pagination(records)
    page = if records.respond_to? :per
             records
           else
             records.page(params[:page])
           end
    return page_entries_info(page) if page.empty?

    page_entries_info(page) +
      capture { yield page } +
      paginate(page)
  end
end
