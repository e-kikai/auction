class System::FollowsController < System::ApplicationController
  def index
    @followes = Follow.unscoped.all.includes(:user, :to_user).order(created_at: :desc)
    @pfollowes = @followes.page(params[:page]).per(500)
  end
end
