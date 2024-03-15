# frozen_string_literal: true

class Api::V1::LoginsController < Api::V1::BaseController
  # skip_before_action :authenticate_user!

  def create
    user = User.find_by(username: params[:username])
    raise ApplicationError::Unauthorized if user.nil? or !user.valid_password?(params[:password])

    render json: {
      user: ActiveModelSerializers::SerializableResource.new(
        user, serializer: Api::V1::UserSerializer
      ),
      token: user.create_auth_token
    }
  end
end
