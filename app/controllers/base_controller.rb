# frozen_string_literal: true

class BaseController < ApplicationController
  helper FontAwesome5Helper
  helper FormatHelper
  helper CsvHelper
  helper LinkToHelper
  helper PaginationHelper
  helper UrlHelper
  helper Theme::Bootstrap4Helper

  private

  def send_csv(csv, options = nil)
    options ||= {}
    send_data csv, type: 'text/csv; charset=utf-8', **options
  end

  def redirect_to_back(response_status = {})
    redirect_back fallback_location: root_path, **response_status
  end

  def redirect_to_params_referrer_or(options = {}, response_status = {})
    if params[:referrer].present?
      redirect_to params[:referrer], response_status
    else
      redirect_to options, response_status
    end
  end
end
