# frozen_string_literal: true

class PartsController < ApplicationController
  def new
    @part = Part.new(part_defaults)
  end

  def create
    @part = Part.new(part_params)
    normalize_machine_for_unit(@part)
    if @part.save
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Partを作成しました。' }
        format.turbo_stream { render_crud_success('Partを作成しました。') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @part = Part.find(params[:id])
  end

  def update
    @part = Part.find(params[:id])
    @part.assign_attributes(part_params)
    normalize_machine_for_unit(@part)
    if @part.save
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Partを更新しました。' }
        format.turbo_stream { render_crud_success('Partを更新しました。') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    part = Part.find(params[:id])
    part.destroy!
    respond_to do |format|
      format.html { redirect_to machines_path, notice: 'Partを削除しました。' }
      format.turbo_stream { render_crud_success('Partを削除しました。') }
    end
  end

  private

  def part_defaults
    if params[:unit_id].present?
      unit = Unit.find(params[:unit_id])
      { unit_id: unit.id, machine_id: unit.machine_id }
    else
      { machine_id: params[:machine_id] }
    end
  end

  def part_params
    params.require(:part).permit(:name, :machine_id, :unit_id)
  end

  def normalize_machine_for_unit(part)
    return unless part.unit_id.present?

    part.machine_id = Unit.find(part.unit_id).machine_id
  end

  def render_crud_success(message)
    flash.now[:notice] = message
    render turbo_stream: [
      turbo_stream.update('flash_messages', partial: 'shared/flash_message'),
      turbo_stream.update('modal', '')
    ]
  end
end
