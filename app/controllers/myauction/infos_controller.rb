class Myauction::InfosController < Myauction::ApplicationController
  def index
    @infos = Info.where(target: 100).where("start_at <= ?", Time.now).order(:start_at)
  end

  def show
    @infos = Info.where(target: 100).where("start_at <= ?", Time.now).order(:start_at)

    @info  = Info.where(target: 100).find(params[:id])
  end
end
