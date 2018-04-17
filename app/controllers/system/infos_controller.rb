class System::InfosController < System::ApplicationController
  def index
    @search = Info.search(params[:q])

    @infos  = @search.result.order(start_at: :desc)
    @pinfos = @infos.page(params[:page])
  end

  def new
    @info = Info.new
  end

  def create
    @info = Info.new(info_params)

    if @info.save
      redirect_to "/system/infos/", notice: "#{@info.title}を登録しました"
    else
      render :new
    end
  end

  def edit
    @info = Info.find(params[:id])
  end

  def update
    @info = Info.find(params[:id])

    if @info.update(info_params)
      redirect_to "/system/infos/", notice: "#{@info.title}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @info = Info.find(params[:id])

    @info.soft_destroy!
    redirect_to "/system/infos/", notice: "#{@info.title}を削除しました"
  end

  private

  def info_params
    params.require(:info).permit(:title, :content, :target, :start_at)
  end
end
