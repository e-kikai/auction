class System::TotalController < System::ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    @companies = User.companies.order(:id)

    respond_to do |format|
      format.html
      format.pdf {
        send_data render_to_string,
          filename:     "total_#{@date.strftime('%Y%m')}",
          content_type: "application/pdf",
          disposition:  "inline"
      }
      format.csv { export_csv "total.csv" }
    end
  end
end
