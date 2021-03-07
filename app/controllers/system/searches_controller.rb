class System::SearchesController < System::ApplicationController
  include MonthSelector
  include Exports

  before_action :month_selector

  def index
    @searches = Search.unscoped.includes(:user, :category, :company)
      .where(created_at: @rrange).order(created_at: :desc)
    @search_log_counts = SearchLog.group(:search_id).where(search_id: @searches.select(:id)).count

    respond_to do |format|
      format.html {
        @psearches = @searches.page(params[:page]).per(100)
      }
      format.csv { export_csv "search_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
