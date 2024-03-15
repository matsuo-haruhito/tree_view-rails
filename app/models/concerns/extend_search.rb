# frozen_string_literal: true

module ExtendSearch
  extend ActiveSupport::Concern

  included do
    # 日付の範囲検索
    scope :from_to_date_search, lambda { |attribute, from, to|
      result = self

      from_date = begin
        from&.to_date
      rescue StandardError
        nil
      end
      to_date = begin
        to&.to_date
      rescue StandardError
        nil
      end

      result = result.where("? <= \"#{model.table_name}\".\"#{attribute}\"", from_date) if from_date.present?

      result = result.where("\"#{model.table_name}\".\"#{attribute}\" < ?", to_date + 1) if to_date.present?

      result
    }

    # 部分一致検索
    scope :partial_match_search, lambda { |attribute, text|
      result = self

      return result if text.nil?

      text.scan(/[^[:blank:]]+/).each do |word|
        result = result.where("\"#{model.table_name}\".\"#{attribute}\" ILIKE ?", "%#{sanitize_sql_like(word)}%")
      end

      result
    }

    # 前方一致検索
    scope :prefix_search, lambda { |attribute, text|
      return if text.nil? || text.blank?

      where("\"#{model.table_name}\".\"#{attribute}\" ILIKE ?", "#{sanitize_sql_like(text.strip)}%")
    }

    # 番号系の検索
    # 全角数字でも検索できるようにする
    scope :number_search, lambda { |attribute, text|
      result = self

      return result if text.nil?

      text.scan(/[^[:blank:]]+/).each do |word|
        word = word.unicode_normalize(:nfkc)
        result = result.where("\"#{model.table_name}\".\"#{attribute}\" ILIKE ?", "%#{sanitize_sql_like(word)}%")
      end

      result
    }
  end
end
