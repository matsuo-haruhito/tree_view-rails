# frozen_string_literal: true

module PaginationHelper
  def page_entries_info(page)
    render 'kaminari/page_entries_info', page: page
  end

  def simple_page_nav(page)
    return ''.html_safe if page.total_pages <= 1

    content_tag(:nav, class: 'mt-2') do
      content_tag(:div, class: 'btn-group') do
        previous = if page.prev_page
                     link_to('前へ', url_for(request.query_parameters.merge(page: page.prev_page)), class: 'btn btn-sm btn-outline-secondary')
                   else
                     content_tag(:span, '前へ', class: 'btn btn-sm btn-outline-secondary disabled')
                   end

        current = content_tag(:span, "#{page.current_page} / #{page.total_pages}", class: 'btn btn-sm btn-outline-secondary disabled')

        following = if page.next_page
                      link_to('次へ', url_for(request.query_parameters.merge(page: page.next_page)), class: 'btn btn-sm btn-outline-secondary')
                    else
                      content_tag(:span, '次へ', class: 'btn btn-sm btn-outline-secondary disabled')
                    end

        safe_join([previous, current, following])
      end
    end
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
