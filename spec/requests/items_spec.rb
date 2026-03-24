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

  describe 'POST /items' do
    it 'Itemを作成して一覧へ戻る' do
      expect do
        post items_path, params: { item: { name: 'new item', comment: 'memo', parent_item_id: nil } }
      end.to change(Item, :count).by(1)

      expect(response).to redirect_to(items_path)
    end
  end

  describe 'PATCH /items/:id' do
    it 'Itemを更新して一覧へ戻る' do
      item = create(:item, name: 'before')

      patch item_path(item), params: { item: { name: 'after', comment: item.comment, parent_item_id: item.parent_item_id } }

      expect(response).to redirect_to(items_path)
      expect(item.reload.name).to eq('after')
    end
  end

  describe 'DELETE /items/:id' do
    it 'Itemを削除して一覧へ戻る' do
      item = create(:item)

      expect do
        delete item_path(item)
      end.to change(Item, :count).by(-1)

      expect(response).to redirect_to(items_path)
    end
  end

  describe 'GET /items/:id/show_descendants.turbo_stream' do
    it '子要素を描画するTurbo Streamレスポンスを返す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')

      get show_descendants_item_path(root, depth: 1), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include(%(target="item_#{root.id}"))
      expect(response.body).to include(%(item_#{child.id}))
    end
  end

  describe 'GET /items?collapsed=all' do
    it 'ルートだけを表示して子孫数を隠れ件数として出す' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')

      get items_path(collapsed: 'all')

      expect(response).to have_http_status(:success)
      expect(response.body).to include('すべて広げる')
      expect(response.body).to include('すべて畳む')
      expect(response.body).to include(%(item_#{root.id}))
      expect(response.body).not_to include(%(item_#{child.id}))
      expect(response.body).to include('tree-toggle__hidden-count')
    end
  end

  describe 'GET /items?page=2' do
    it 'root 単位でページネーションされ、子は親と同じページに残る' do
      10.times { |i| create(:item, name: "root#{i}") }
      target_root = create(:item, name: 'root10')
      child = create(:item, parent_item_id: target_root.id, name: 'child10')

      get items_path(page: 2)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('root10')
      expect(response.body).to include('child10')
      expect(response.body).not_to include('root0')
      expect(response.body).to include('前へ')
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

    it 'scope=children では子ノード配下だけを削除する' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')
      grandchild = create(:item, parent_item_id: child.id, name: 'grandchild')

      get remove_descendants_item_path(root, depth: 1, scope: 'children'),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include(%(target="item_#{child.id}" action="remove"))
      expect(response.body).to include(%(target="item_#{grandchild.id}"))
      expect(response.body).to include('tree-toggle__hidden-count')
    end

    it 'scope=grandchildren では孫ノード配下だけを削除する' do
      root = create(:item, name: 'root')
      child = create(:item, parent_item_id: root.id, name: 'child')
      grandchild = create(:item, parent_item_id: child.id, name: 'grandchild')
      great_grandchild = create(:item, parent_item_id: grandchild.id, name: 'great-grandchild')

      get remove_descendants_item_path(root, depth: 1, scope: 'grandchildren'),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include(%(target="item_#{grandchild.id}" action="remove"))
      expect(response.body).to include(%(target="item_#{great_grandchild.id}"))
      expect(response.body).to include(%(target="item_button_box_#{grandchild.id}"))
    end
  end
end
