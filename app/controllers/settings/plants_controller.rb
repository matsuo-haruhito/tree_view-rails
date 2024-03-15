# frozen_string_literal: true

class Settings::PlantsController < BaseController
  # 追加
  def search
    @plants = Plant.where("name like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.js
    end
  end
end
