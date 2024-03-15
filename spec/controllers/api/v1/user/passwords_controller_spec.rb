# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::User::PasswordsController, type: :controller do
  describe '#update' do
    example 'success' do
      user = create(:user)
      request.headers.merge!({
                               'Authorization' => "Bearer #{user.create_auth_token}"
                             })
      body = { password: 'new_password' }.to_json

      post :update, body: body, as: :json
      result = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq 200
      expect(result[:token]).not_to eq nil
      expect(result[:message]).to eq 'パスワードの変更に成功しました'
    end

    example 'validation error' do
      user = create(:user)
      request.headers.merge!({
                               'Authorization' => "Bearer #{user.create_auth_token}"
                             })
      body = { password: 'a' }.to_json

      post :update, body: body, as: :json
      result = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq 422
      expect(result[:token]).to eq nil
      expect(result[:message]).to eq nil
      expect(result[:errors]).not_to eq nil
    end

    example 'without token' do
      body = { password: 'new_password' }.to_json

      post :update, body: body, as: :json
      result = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq 401
      expect(result[:message]).to eq 'Authentication failed'
    end
  end
end
