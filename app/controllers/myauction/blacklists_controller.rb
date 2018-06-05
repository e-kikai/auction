class Myauction::BlacklistsController < Myauction::ApplicationController
  before_action :check_seller

  def index
    @blacklists = current_user.blacklists.order(id: :desc)
    @pblacklists = @blacklists.page(params[:page]).preload(:to_user)
  end

  def new
    @account = params[:account]
  end

  def create
    @user = User.find_by(account: params[:account])

    if @user.blank?
      redirect_to "/myauction/blacklists", notice: "「#{params[:account]}」はユーザ情報がありませんでした"
    else
      @blacklist = current_user.blacklists.new(to_user_id: @user.id)
      if @blacklist.save
        redirect_to "/myauction/blacklists", notice: "「#{params[:account]}」をブラックリストに登録しました"
      else
        redirect_to "/myauction/blacklists", alert: "「#{params[:account]}」は既にブラックリストに登録されています"
      end
    end
  end

  def destroy
    @blacklist = current_user.blacklists.find(params[:id])
    @blacklist.soft_destroy!
    redirect_to "/myauction/blacklists/", notice: "ブラックリストから出品会社を削除しました"
  end
end
