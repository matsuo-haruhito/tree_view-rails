# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchText do
  describe 'normalize' do
    example 'no change' do
      expect(SearchText.normalize('abcdefghijklmnopqrstuvwxyz')).to eq 'abcdefghijklmnopqrstuvwxyz'
      expect(SearchText.normalize('0123456789')).to eq '0123456789'
      expect(SearchText.normalize("!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")).to eq "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
      expect(SearchText.normalize(' ')).to eq ' '
      expect(SearchText.normalize('漢字')).to eq '漢字'
    end

    example 'to lower case' do
      expect(SearchText.normalize('ABCDEFGHIJKLMNOPQRSTUVWXYZ')).to eq 'abcdefghijklmnopqrstuvwxyz'
    end

    example 'to half width' do
      expect(SearchText.normalize('０１２３４５６７８９')).to eq '0123456789'
      expect(SearchText.normalize('ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ')).to eq 'abcdefghijklmnopqrstuvwxyz'
      expect(SearchText.normalize('ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ')).to eq 'abcdefghijklmnopqrstuvwxyz'
      expect(SearchText.normalize('　')).to eq ' '
      expect(SearchText.normalize('！＂＃＄％＆＇（）＊＋，－．／：；＜＝＞？＠［＼］＾＿｀｛｜｝～')).to eq "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
    end

    example 'to katakana' do
      expect(SearchText.normalize('あいうえお')).to eq 'アイウエオ'
      expect(SearchText.normalize('ｱｲｳｴｵ')).to eq 'アイウエオ'
      expect(SearchText.normalize('ゔ')).to eq 'ヴ'
      expect(SearchText.normalize('う゛')).to eq 'ヴ'
    end

    example 'unicode_normalize' do
      expect(SearchText.normalize('㍑')).to eq 'リットル'
      expect(SearchText.normalize('㍻')).to eq '平成'
      expect(SearchText.normalize('㈱')).to eq '(株)'
      expect(SearchText.normalize('①')).to eq '1'
    end

    example 'emoji' do
      expect(SearchText.normalize('寿司🍣すし')).to eq '寿司🍣スシ'
    end

    example 'nil' do
      expect(SearchText.normalize(nil)).to eq nil
    end
  end
end
