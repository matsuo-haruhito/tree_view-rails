# frozen_string_literal: true

module LinkToHelper
  def new_link_to(name, url, options = {})
    default_option = {
      class: 'btn btn-primary'
    }
    options = default_option.merge(options)
    link_to name, url, options
  end

  def show_link_to(name, url, options = {})
    default_option = {
      class: 'btn btn-info'
    }
    options = default_option.merge(options)
    link_to name, url, options
  end

  def pdf_link_to(name, url, options = {})
    default_option = {
      class: 'btn btn-info'
    }
    options = default_option.merge(options)
    link_to url, options do
      tag.i(class: 'fas fa-file-pdf') + name
    end
  end

  def edit_link_to(name, url, options = {})
    default_option = {
      class: 'btn btn-primary'
    }
    options = default_option.merge(options)
    link_to name, url, options
  end

  def delete_link_to(name, url, options = {})
    default_option = {
      class: 'btn btn-danger',
      method: :delete,
      data: { title: '確認',
              confirm: '選択した項目を削除しますか？' }
      # 'commit-class': 'btn-danger',
    }
    options = default_option.merge(options)
    link_to name, url, options
  end

  def download_link_to(url, options = {}, &block)
    default_option = {
      class: 'btn btn-info'
    }
    options = default_option.merge(options)
    link_to url, options, &block
  end

  def sort_link_to(name, options = nil, &block)
    options ||= {}

    sort = params[:sort].to_s
      .split(',')
      .find { |it| it.delete_prefix('-') == name.to_s }

    if name.to_s == sort&.delete_prefix('-')
      icon = if sort.start_with?('-')
               fas('sort-down')
             else
               fas('sort-up')
             end
    end

    link_to sort_url(name), options do
      capture(&block) + icon
    end
  end
end
