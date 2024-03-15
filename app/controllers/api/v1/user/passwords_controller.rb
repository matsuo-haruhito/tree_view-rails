# frozen_string_literal: true

class Api::V1::User::PasswordsController < Api::V1::BaseController
  before_action :authenticate_user!

  def update
    user = User.find(current_user_id)

    if user.update(params.permit(:password))
      render json: {
        message: 'パスワードの変更に成功しました',
        token: user.create_auth_token
      }
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
