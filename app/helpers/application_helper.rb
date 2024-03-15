# frozen_string_literal: true

module ApplicationHelper
  def hidden_referrer
    value = if params[:referrer].nil?
              request.referer
            else
              params[:referrer]
            end
    hidden_field_tag 'referrer', value, id: nil
  end

  def checkmark(value)
    '✔' if value == true
  end

  # I18n.lの引数がnilの時にエラーにならないようにする
  def l(object, **options)
    return if object.nil?

    super
  end
end
