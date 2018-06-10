class Myauction::CsvController < Myauction::ApplicationController
  before_action :check_seller

  def new
    # @template_selectors  = current_user.products.templates.pluck(:name, :id)
  end

  def confirm
    # redirect_to "/myauction/csv/new", alert: 'CSVファイルを選択してください' if params[:file].blank?
    #
    # @category = Category.find(params[:category_id])
    # @template = current_user.products.templates.find(params[:template_id])

    # @res = current_user.products.import_conf(params[:file], params[:category_id], @template)
    @res = Product.import_conf(params[:file], current_user)

    redirect_to "/myauction/csv/new", alert: 'インポートする商品情報がありませんでした' if @res.length == 0
  end

  def create
    num = csv_products_params.length

    redirect_to "/myauction/csv/new", alert: 'インポートする商品がありません' if num == 0

    # @category = Category.find(params[:category_id])
    # @template = current_user.products.templates.find(params[:template_id])

    # current_user.products.import(csv_products_params, params[:category_id], @template, current_user.id)
    Product.import(csv_products_params, current_user)

    redirect_to("/myauction/", notice: "#{num.to_s}件の商品をインポートしました")
  end

  def progress
    render json: { progress: current_user.products.count }
  end

  private

  def csv_products_params
    params.require(:products).map { |p| p.permit(:code, :category_id, :template_id, :name, :description, :dulation_start, :dulation_end, :start_price, :lower_price, :prompt_dicision_price, :hashtags, :machinelife_id, :machinelife_images)}
  end
end
