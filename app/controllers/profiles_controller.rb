# frozen_string_literal: true

class ProfilesController < BaseController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      bypass_sign_in(@user)
      redirect_to_params_referrer_or root_path, notice: 'ユーザ情報の更新に成功しました'
    else
      flash.now[:alert] = @user.errors
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :username,
      :name,
      :furigana,
      :password
    )
  end
end
