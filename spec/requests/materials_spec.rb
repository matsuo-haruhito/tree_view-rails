require 'rails_helper'

RSpec.describe 'Materials', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it 'Materialを作成できる' do
    part = create(:part)

    expect do
      post materials_path, params: { material: { name: 'Material A', part_id: part.id } }
    end.to change(Material, :count).by(1)

    expect(response).to redirect_to(machines_path)
  end

  it 'Materialを更新できる' do
    material = create(:material)

    patch material_path(material), params: { material: { name: 'Material B', part_id: material.part_id } }

    expect(response).to redirect_to(machines_path)
    expect(material.reload.name).to eq('Material B')
  end

  it 'Materialを削除できる' do
    material = create(:material)

    expect do
      delete material_path(material)
    end.to change(Material, :count).by(-1)

    expect(response).to redirect_to(machines_path)
  end
end
