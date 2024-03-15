# frozen_string_literal: true

module SearchText
  # 曖昧検索用に文字列を半角英数字・全角カタカナに変換する
  def self.normalize(text)
    return if text.nil?

    result = text
    result = result.gsub('う゛', 'ヴ')
    result = result.unicode_normalize(:nfkc).downcase
    result = NKF.nkf('-w -W --katakana', result)
  end
end
