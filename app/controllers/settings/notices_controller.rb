# frozen_string_literal: true

class Settings::NoticesController < BaseController
  before_action :apply_rparam

  def index
    @notices = Notice
      .search(params)
      .order_by(params[:sort])
  end

  def new
    @notice = Notice.new(
      publish_start_datetime: Time.current
    )
  end

  def edit
    @notice = find_notice
  end

  def create
    @notice = Notice.new(notice_params)
    @notice.created_by(current_user)
    if @notice.save
      redirect_to_params_referrer_or url_for(action: :index), notice: 'お知らせの登録に成功しました'
    else
      flash.now[:alert] = @notice.errors
      render :new
    end
  end

  def update
    @notice = find_notice
    @notice.updated_by(current_user)
    if @notice.update(notice_params)
      redirect_to_params_referrer_or url_for(action: :index), notice: 'お知らせの更新に成功しました'
    else
      flash.now[:alert] = @notice.errors
      render :edit
    end
  end

  def destroy
    @notice = find_notice
    if @notice.destroy
      redirect_to_back notice: 'お知らせの削除に成功しました'
    else
      redirect_to_back alert: @notice.errors.full_messages
    end
  end

  private

  def find_notice
    Notice.find(params[:id])
  end

  def notice_params
    params.require(:notice).permit(
      :title,
      :body,
      :publish_start_datetime,
      :publish_end_datetime
    )
  end
end
