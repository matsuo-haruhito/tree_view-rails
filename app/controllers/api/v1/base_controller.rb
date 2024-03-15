# frozen_string_literal: true

class Api::V1::BaseController < ActionController::API
  include JwtAuthenticate

  # before_action :authenticate_user!

  before_action do
    params.deep_snakeize!
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { message: 'Not Found' }, status: :not_found
  end

  rescue_from ApplicationError::Unauthorized do
    render json: { message: 'Authentication failed' }, status: :unauthorized
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { message: e }, status: :bad_request
  end
end
