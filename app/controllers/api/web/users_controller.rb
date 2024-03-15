# frozen_string_literal: true

class Api::Web::UsersController < Api::Web::BaseController
  def index
    users = User
      .search(params)
      .order(:furigana)
      .page(params[:page])
      .per(params[:per])

    render json: users, include: params[:include]
  end
end
