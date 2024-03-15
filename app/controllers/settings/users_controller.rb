# frozen_string_literal: true

class Settings::UsersController < BaseController
  before_action :apply_rparam

  def index
    @users = User
      .search(params)
      .order_by(params[:sort])
  end

  def new
    @user = User.new
  end

  def edit
    @user = find_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to_params_referrer_or url_for(action: :index), notice: 'ユーザの登録に成功しました'
    else
      flash.now[:alert] = @user.errors
      render :new
    end
  end

  def update
    @user = find_user
    update_current_user = @user == current_user
    if @user.update(user_params)
      bypass_sign_in(@user) if update_current_user
      redirect_to_params_referrer_or url_for(action: :index), notice: 'ユーザの更新に成功しました'
    else
      flash.now[:alert] = @user.errors
      render :edit
    end
  end

  def destroy
    @user = find_user
    if @user.admin?
      redirect_to_back alert: '管理者権限のユーザを削除することはできません'
      return
    end

    if @user.destroy
      redirect_to_back notice: 'ユーザの削除に成功しました'
    else
      redirect_to_back alert: @user.errors.full_messages
    end
  end

  private

  def find_user
    User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :username,
      :name,
      :furigana,
      :password
    )
  end
end
