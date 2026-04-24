# frozen_string_literal: true

class MaterialsController < ApplicationController
  def new
    @material = Material.new(part_id: params[:part_id])
  end

  def create
    @material = Material.new(material_params)
    if @material.save
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Materialを作成しました。' }
        format.turbo_stream { render_crud_success('Materialを作成しました。') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @material = Material.find(params[:id])
  end

  def update
    @material = Material.find(params[:id])
    if @material.update(material_params)
      respond_to do |format|
        format.html { redirect_to machines_path, notice: 'Materialを更新しました。' }
        format.turbo_stream { render_crud_success('Materialを更新しました。') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    material = Material.find(params[:id])
    material.destroy!
    respond_to do |format|
      format.html { redirect_to machines_path, notice: 'Materialを削除しました。' }
      format.turbo_stream { render_crud_success('Materialを削除しました。') }
    end
  end

  private

  def material_params
    params.require(:material).permit(:name, :part_id)
  end

  def render_crud_success(message)
    flash.now[:notice] = message
    render turbo_stream: [
      turbo_stream.update('flash_messages', partial: 'shared/flash_message'),
      turbo_stream.update('modal', '')
    ]
  end
end
