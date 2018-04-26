class InfosController < ApplicationController
  def index
    @infos = Info.where(target: 0).where("start_at <= ?", Time.now).order(:start_at)
  end

  def show
    @infos = Info.where(target: 0).where("start_at <= ?", Time.now).order(:start_at)

    @info  = Info.where(target: 0).find_by(uid: params[:id])
  end
end
