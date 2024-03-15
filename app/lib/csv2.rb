# frozen_string_literal: true

# 文字コードを気にせずに読み込めるようにしたCSVクラス
class Csv2
  class << self
    def read(path, options = {})
      parse(File.read(path), **options)
    end

    def parse(text, options = {})
      if text.force_encoding('utf-8').valid_encoding?
        text = text.force_encoding('utf-8')
      elsif text.force_encoding('sjis').valid_encoding?
        text = text.force_encoding('sjis').encode('utf-8')
      end

      CSV.parse(text, **options)
    end
  end
end
