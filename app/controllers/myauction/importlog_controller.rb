class Myauction::ImportlogController < Myauction::ApplicationController
  def index
    @importlogs  = current_user.importlogs.order(id: :desc)
    @pimportlogs = @importlogs.page(params[:page])
  end
end
