require 'rails_helper'

RSpec.describe 'items/new', type: :view do
  it 'Item作成フォームが表示される' do
    assign(:item, Item.new)

    render

    expect(rendered).to include('Item作成')
    expect(rendered).to include('商品名')
    expect(rendered).to include('コメント')
    expect(rendered).to include('turbo-frame')
  end
end
