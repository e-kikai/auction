class System::SearchesController < System::ApplicationController
  def index
    @searches = Search.unscoped.all.includes(:user, :category, :company).order(created_at: :desc)
    @psearches = @searches.page(params[:page]).per(500)

    @search_log_counts = SearchLog.group(:search_id).where(search_id: @searches.select(:id)).count

  end
end
