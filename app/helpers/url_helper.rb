# frozen_string_literal: true

module UrlHelper
  def sort_url(name)
    query = URI.parse(request.url).query || ''

    query_hash = {}

    URI.decode_www_form(query).each do |name, value|
      if name.end_with?('[]')
        name = name.delete_suffix('[]')
        query_hash[name] ||= []
        query_hash[name] << value
      else
        query_hash[name] = value
      end
    end

    query_hash = query_hash.transform_keys(&:to_sym)

    query_hash.delete :page

    name = "-#{name}" if name.to_s == params[:sort].to_s

    url_for(params: query_hash.merge(sort: name))
  end

  def csv_url(options = nil)
    url = url_for(format: :csv)

    query = URI.parse(request.url).query
    url = url + '?' + query if query.present?

    if options.present?
      url = if url.include? '?'
              url + '&' + options.to_query
            else
              url + '?' + options.to_query
            end
    end

    url
  end
end
