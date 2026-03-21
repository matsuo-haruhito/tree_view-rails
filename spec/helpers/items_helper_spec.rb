require 'rails_helper'

RSpec.describe ItemsHelper, type: :helper do
  describe '#remove_descendants_link' do
    it '閉じるリンクをTurbo Stream付きで生成する' do
      item = create(:item)
      html = helper.remove_descendants_link(item, 2)

      expect(html).to include('remove_descendants')
      expect(html).to include('depth=3')
      expect(html).to include('data-turbo-stream="true"')
    end
  end

  describe '#show_descendants_link' do
    it '開くリンクをTurbo Stream付きで生成する' do
      item = create(:item)
      html = helper.show_descendants_link(item, 3)

      expect(html).to include('show_descendants')
      expect(html).to include('depth=3')
      expect(html).to include("id=\"show_button_#{item.id}\"")
      expect(html).to include('data-turbo-stream="true"')
      expect(html).to include('>2<')
    end
  end
end
