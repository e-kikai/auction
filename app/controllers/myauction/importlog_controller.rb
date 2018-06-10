class Myauction::ImportlogController < Myauction::ApplicationController
  before_action :check_seller

  def index
    @importlogs  = current_user.importlogs.order(id: :desc)
    @pimportlogs = @importlogs.page(params[:page])
  end
end
