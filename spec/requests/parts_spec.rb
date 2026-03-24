require 'rails_helper'

RSpec.describe 'Parts', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it 'Partを作成できる' do
    machine = create(:machine)

    expect do
      post parts_path, params: { part: { name: 'Part A', machine_id: machine.id, unit_id: nil } }
    end.to change(Part, :count).by(1)

    expect(response).to redirect_to(machines_path)
  end

  it 'Partを更新できる' do
    part = create(:part)

    patch part_path(part), params: { part: { name: 'Part B', machine_id: part.machine_id, unit_id: part.unit_id } }

    expect(response).to redirect_to(machines_path)
    expect(part.reload.name).to eq('Part B')
  end

  it 'Partを削除できる' do
    part = create(:part)

    expect do
      delete part_path(part)
    end.to change(Part, :count).by(-1)

    expect(response).to redirect_to(machines_path)
  end
end
