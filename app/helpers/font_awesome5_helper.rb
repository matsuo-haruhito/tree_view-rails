# frozen_string_literal: true

module FontAwesome5Helper
  def fa_icon(style, name, text = nil, html_options = {})
    if text.is_a?(Hash)
      html_options = text
      text = nil
    end

    name = name.split(' ') if name.is_a? String

    name = name.map { |n| "fa-#{n}" }.join(' ') if name.is_a? Array

    content_class = "#{style} #{name}"
    content_class += " #{html_options[:class]}" if html_options.key?(:class)
    html_options[:class] = content_class

    html = content_tag(:i, nil, html_options)
    html << ' ' << text.to_s if text.present?
    html
  end

  def far(*args)
    fa_icon('far', *args)
  end

  def fas(*args)
    fa_icon('fas', *args)
  end
end
