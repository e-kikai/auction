class System::BlacklistsController < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector

  def index
    @blacklists = Blacklist.includes(:user, :to_user).where(created_at: @rrange).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @pblacklists = @blacklists.page(params[:page]).per(100)
      }
      format.csv { export_csv "blacklists_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

end
