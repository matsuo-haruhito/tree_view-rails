# frozen_string_literal: true

require 'rails_helper'

# NOTE:
# Estimates関連機能は現行アプリから削除済みのため、回帰用specとしてskipして残す。
RSpec.describe 'Estimates::WorkInstructionsController', type: :request, skip: 'Estimates機能は現行スコープ外' do
  describe 'GET /estimates/:estimate_id/work_instruction' do
    before do
      sign_in create(:user)
    end

    example '作業記録がある' do
      estimate = create(:estimate)
      work_record = create(:work_record,
                           estimate: estimate)
      get estimate_work_instruction_path(estimate)
      expect(response).to redirect_to(estimate_work_record_work_instruction_path(estimate, work_record, format: :pdf))
    end

    example '作業記録が複数ある' do
      estimate = create(:estimate)
      work_record1 = create(:work_record,
                            estimate: estimate)
      work_record2 = create(:work_record,
                            estimate: estimate)
      get estimate_work_instruction_path(estimate)
      expect(response).to redirect_to(estimate_work_record_work_instruction_path(estimate, work_record1, format: :pdf))
    end

    example '作業記録がない' do
      estimate = create(:estimate)
      expect { get estimate_work_instruction_path(estimate) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
