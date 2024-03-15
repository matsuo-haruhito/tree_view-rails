# frozen_string_literal: true

module JwtAuthenticate
  extend ActiveSupport::Concern

  def authenticate_user!
    raise ApplicationError::Unauthorized if current_user.nil?
  end

  def current_user
    return if auth_token.nil?

    user = User.find(auth_token[:user_id])

    user if auth_token[:jti] == user.jti
  rescue StandardError
    nil
  end

  def current_user_id
    current_user&.id
  end

  def auth_token
    token = request.headers['Authorization'][7..-1] if request.headers['Authorization'].start_with? 'Bearer '
    ActiveSupport::HashWithIndifferentAccess.new JWT.decode(token, ENV.fetch('SECRET_KEY_BASE', nil), true)[0]
  rescue StandardError
    nil
  end
end
