# frozen_string_literal: true

class Api::Web::PlantsController < Api::Web::BaseController
  def index
    plants = Plant
      .page(params[:page])
      .per(params[:per])

    render json: plants, include: params[:include]
  end
end
