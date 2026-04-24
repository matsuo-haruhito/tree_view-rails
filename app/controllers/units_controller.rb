# frozen_string_literal: true

class UnitsController < ApplicationController
  def new
    @unit = Unit.new(unit_defaults)
  end

  def create
    @unit = Unit.new(unit_params)
    if @unit.save
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Unitを作成しました。' }
        format.turbo_stream { render_crud_success('Unitを作成しました。') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @unit = Unit.find(params[:id])
  end

  def update
    @unit = Unit.find(params[:id])
    if @unit.update(unit_params)
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Unitを更新しました。' }
        format.turbo_stream { render_crud_success('Unitを更新しました。') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unit = Unit.find(params[:id])
    unit.destroy!
    respond_to do |format|
      format.html { redirect_to machines_path, notice: 'Unitを削除しました。' }
      format.turbo_stream { render_crud_success('Unitを削除しました。') }
    end
  end

  private

  def unit_defaults
    if params[:parent_unit_id].present?
      parent_unit = Unit.find(params[:parent_unit_id])
      { parent_unit_id: parent_unit.id, machine_id: parent_unit.machine_id }
    else
      { machine_id: params[:machine_id] }
    end
  end

  def unit_params
    params.require(:unit).permit(:name, :machine_id, :parent_unit_id)
  end

  def render_crud_success(message)
    flash.now[:notice] = message
    render turbo_stream: [
      turbo_stream.update('flash_messages', partial: 'shared/flash_message'),
      turbo_stream.update('modal', '')
    ]
  end
end
