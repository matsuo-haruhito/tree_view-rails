# frozen_string_literal: true

module FormatHelper
  include ActionView::Helpers::NumberHelper

  def format_date(date, format = '%Y/%m/%d')
    return if date.nil?

    date.strftime(format)
  end

  def format_datetime(datetime, format = '%Y/%m/%d %H:%M:%S')
    return if datetime.nil?

    datetime.strftime(format)
  end

  def format_number(number, suffix: nil)
    return if number.nil?

    "#{number_with_delimiter(number)}#{suffix}"
  end

  def format_percent(value)
    return if value.nil?

    percent = value * 100
    if percent.to_i == percent
      # 小数点以下が0のときは.0以下を省略する
      "#{percent.to_i}%"
    else
      "#{percent}%"
    end
  end
end
