# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Estimates::WorkRecords::WorkInstructionsController, type: :request do
  describe 'GET /estimates/:estimate_id/work_records/:work_record_id/work_instruction' do
    before do
      sign_in create(:user)
    end

    example '拡張子無しでpdfにリダイレクトされる' do
      estimate = create(:estimate)
      work_record = create(:work_record,
                           estimate: estimate)
      get estimate_work_record_work_instruction_path(estimate, work_record)
      expect(response).to redirect_to(estimate_work_record_work_instruction_path(estimate, work_record, format: :pdf))
    end
  end
end
