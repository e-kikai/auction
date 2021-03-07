class System::FollowsController < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector

  def index
    @follows = Follow.unscoped.includes(:user, :to_user)
      .where(created_at: @rrange).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @pfollows = @follows.page(params[:page]).per(100)
      }
      format.csv { export_csv "follow_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
