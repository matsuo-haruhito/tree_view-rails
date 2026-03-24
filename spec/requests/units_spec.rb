require 'rails_helper'

RSpec.describe 'Units', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it 'Unitを作成できる' do
    machine = create(:machine)

    expect do
      post units_path, params: { unit: { name: 'Unit A', machine_id: machine.id, parent_unit_id: nil } }
    end.to change(Unit, :count).by(1)

    expect(response).to redirect_to(machines_path)
  end

  it 'Unitを更新できる' do
    unit = create(:unit)

    patch unit_path(unit), params: { unit: { name: 'Unit B', machine_id: unit.machine_id, parent_unit_id: unit.parent_unit_id } }

    expect(response).to redirect_to(machines_path)
    expect(unit.reload.name).to eq('Unit B')
  end

  it 'Unitを削除できる' do
    unit = create(:unit)

    expect do
      delete unit_path(unit)
    end.to change(Unit, :count).by(-1)

    expect(response).to redirect_to(machines_path)
  end
end
