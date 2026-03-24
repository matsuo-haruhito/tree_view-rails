require 'rails_helper'

RSpec.describe 'Machines', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /machines' do
    it '正常に表示できる' do
      create(:machine, name: '機械A')

      get machines_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('機械A')
      expect(response.body).to include('Adapter/BOM版')
      expect(response.body).to include('ノードキー')
      expect(response.body).to include('turbo-cable-stream-source')
    end
  end

  describe 'POST /machines' do
    it 'Machineを作成して一覧へ戻る' do
      expect do
        post machines_path, params: { machine: { name: '機械Z', parent_machine_id: nil } }
      end.to change(Machine, :count).by(1)

      expect(response).to redirect_to(machines_path)
    end
  end

  describe 'PATCH /machines/:id' do
    it 'Machineを更新して一覧へ戻る' do
      machine = create(:machine, name: '機械A')

      patch machine_path(machine), params: { machine: { name: '機械B', parent_machine_id: machine.parent_machine_id } }

      expect(response).to redirect_to(machines_path)
      expect(machine.reload.name).to eq('機械B')
    end
  end

  describe 'DELETE /machines/:id' do
    it 'Machineを削除して一覧へ戻る' do
      machine = create(:machine)

      expect do
        delete machine_path(machine)
      end.to change(Machine, :count).by(-1)

      expect(response).to redirect_to(machines_path)
    end
  end

  describe 'GET /machines?collapsed=all' do
    it 'ルートだけを表示して子孫数を隠れ件数として出す' do
      machine = create(:machine, name: '機械A')
      unit = create(:unit, machine: machine, name: 'ユニットA')

      get machines_path(collapsed: 'all')

      expect(response).to have_http_status(:success)
      expect(response.body).to include('すべて広げる')
      expect(response.body).to include('すべて畳む')
      expect(response.body).to include(%(node_machine_#{machine.id}))
      expect(response.body).not_to include(%(node_unit_#{unit.id}))
      expect(response.body).to include('tree-toggle__hidden-count')
    end
  end

  describe 'GET /machines with global initial_state' do
    it 'global config が collapsed なら collapsed=all なしでもルートだけ表示する' do
      machine = create(:machine, name: '機械A')
      unit = create(:unit, machine: machine, name: 'ユニットA')

      TreeView.configure do |config|
        config.initial_state = :collapsed
      end

      get machines_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(%(node_machine_#{machine.id}))
      expect(response.body).not_to include(%(node_unit_#{unit.id}))
      expect(response.body).to include('tree-toggle__hidden-count')
    end
  end

  describe 'GET /machines?page=2' do
    it 'machine root 単位でページネーションされ、配下ノードは同じページに残る' do
      10.times { |i| create(:machine, name: "機械#{i}") }
      target_machine = create(:machine, name: '機械10')
      unit = create(:unit, machine: target_machine, name: 'ユニット10')

      get machines_path(page: 2)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('機械10')
      expect(response.body).to include('ユニット10')
      expect(response.body).not_to include('機械0')
      expect(response.body).to include('前へ')
    end
  end

  describe 'GET /machines/show_descendants.turbo_stream' do
    it '子ノードを描画するTurbo Streamレスポンスを返す' do
      machine = create(:machine, name: '機械A')
      unit = create(:unit, machine: machine, name: 'ユニットA')

      get show_descendants_machines_path(node_type: 'Machine', node_id: machine.id, depth: 1),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include(%(target="node_machine_#{machine.id}"))
      expect(response.body).to include(%(node_unit_#{unit.id}))
    end
  end

  describe 'GET /machines/remove_descendants.turbo_stream' do
    it '子孫ノードを削除するTurbo Streamレスポンスを返す' do
      machine = create(:machine, name: '機械A')
      unit = create(:unit, machine: machine, name: 'ユニットA')
      part = create(:part, machine: machine, unit: unit, name: '部品A')

      get remove_descendants_machines_path(node_type: 'Machine', node_id: machine.id, depth: 1),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include(%(target="node_unit_#{unit.id}"))
      expect(response.body).to include(%(target="node_part_#{part.id}"))
    end

    it 'scope=children では子ノード配下だけを削除する' do
      machine = create(:machine, name: '機械A')
      unit = create(:unit, machine: machine, name: 'ユニットA')
      part = create(:part, machine: machine, unit: unit, name: '部品A')

      get remove_descendants_machines_path(node_type: 'Machine', node_id: machine.id, depth: 1, scope: 'children'),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include(%(target="node_unit_#{unit.id}" action="remove"))
      expect(response.body).to include(%(target="node_part_#{part.id}"))
      expect(response.body).to include('tree-toggle__hidden-count')
    end

    it 'scope=grandchildren では孫ノード配下だけを削除する' do
      machine = create(:machine, name: '機械A')
      unit = create(:unit, machine: machine, name: 'ユニットA')
      part = create(:part, machine: machine, unit: unit, name: '部品A')
      material = create(:material, part: part, name: '材料A')

      get remove_descendants_machines_path(node_type: 'Machine', node_id: machine.id, depth: 1, scope: 'grandchildren'),
          headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include(%(target="node_part_#{part.id}" action="remove"))
      expect(response.body).to include(%(target="node_material_#{material.id}"))
      expect(response.body).to include(%(target="node_button_box_part_#{part.id}"))
    end
  end
end
