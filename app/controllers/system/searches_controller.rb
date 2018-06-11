class System::SearchesController < System::ApplicationController
  def index
    @searches = Search.all.includes(:user, :category, :company).order(created_at: :desc)
    @psearches = @searches.page(params[:page]).per(500)
  end
end
