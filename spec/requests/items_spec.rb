require 'rails_helper'

RSpec.describe 'Items', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /items/new' do
    it '正常に表示できる' do
      get '/items/new'

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /items/:id/remove_descendants.turbo_stream' do
    it '子孫行を削除するTurbo Streamレスポンスを返す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')
      grandchild = create(:item, parent_item_id: child.id, name: 'grandchild')

      get remove_descendants_item_path(root, depth: 1), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include(%(target="item_#{child.id}"))
      expect(response.body).to include(%(target="item_#{grandchild.id}"))
    end
  end
end
