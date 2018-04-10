class System::HelpsController < System::ApplicationController
  def index
    @search = Help.search(params[:q])

    @helps  = @search.result.order(order_no: :asc)
    @phelps = @helps.page(params[:page])
  end

  def new
    @help = Help.new
  end

  def create
    @help = Help.new(help_params)

    if @help.save
      redirect_to "/system/helps/", notice: "#{@help.title}を登録しました"
    else
      render :new
    end
  end

  def edit
    @help = Help.find(params[:id])
  end

  def update
    @help = Help.find(params[:id])

    if @help.update(help_params)
      redirect_to "/system/helps/", notice: "#{@help.title}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @help = Help.find(params[:id])

    @help.soft_destroy!
    redirect_to "/system/helps/", notice: "#{@help.title}を削除しました"
  end

  private

  def help_params
    params.require(:help).permit(:title, :content, :target, :order_no)
  end
end
