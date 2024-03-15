# frozen_string_literal: true

# csvダウンロード用
module CsvHelper
  include ActionView::Helpers::NumberHelper

  def csv_boolean(value)
    if value == true
      'true'
    elsif value == false
      'false'
    end
  end

  def csv_date(value)
    value&.strftime('%Y/%m/%d')
  end

  def csv_datetime(value)
    value&.strftime('%Y/%m/%d %H:%M:%S')
  end
end
