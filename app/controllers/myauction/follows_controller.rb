class Myauction::FollowsController < Myauction::ApplicationController
  def index
    @follows = current_user.follows.order(id: :desc)
    @pfollows = @follows.page(params[:page]).preload(:to_user)
  end

  def create
    @follow = current_user.follows.new(to_user_id: params[:id])
    if @follow.save
      redirect_to "/myauction/follows", notice: "フォローリストに登録しました"
    else
      redirect_to "/myauction/follows", alert: "既にフォローリストに登録されています"
    end
  end

  def destroy
    @follow = current_user.follows.find_by(to_user_id: params[:id])
    @follow.soft_destroy!
    redirect_to "/myauction/follows/", notice: "フォローリストから出品会社を削除しました"
  end
end
