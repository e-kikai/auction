class Myauction::MainController < Myauction::ApplicationController
  def index
    @user = current_user

    # ヘルプ
    @helps = Help.where(target: 100).order(:order_no).limit(10)
    @infos = Info.where(target: 100).order(start_at: :desc).limit(10)
  end
end
