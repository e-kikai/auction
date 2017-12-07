class Myauction::MainController < Myauction::ApplicationController
  def index
    @user = current_user
  end
end
