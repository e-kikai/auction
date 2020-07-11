class System::CompanyChatsController < System::ApplicationController
  before_action :get_system_user

  def index
    @company_chats = CompanyChat.includes(:user, :res).all.order(id: :desc)

    @pcompany_chats = @company_chats.page(params[:page]).per(30)

    @company_chat = CompanyChat.new

    respond_to do |format|
      format.html
      format.csv { export_csv "chats_list.csv" }
    end
  end

  def create
    @company_chat = CompanyChat.new(chat_params.merge(user_id: @system_user.id))
    if @company_chat.save

      ### 出品会社に返信するときのみ通知メールを送信 ###
      # if @company_chat.res && res.user_id != @system_user.id
      #   BidMailer.trade_user(@trade).deliver
      # end

      redirect_to "/myauction/company_chats", notice: "チャット投稿を行いました"
    else
      flash.now[:alert] = "チャット投稿に失敗しました"
      render :index
    end
  end

  private

  def get_system_user
    @system_user = User.find(@system_user_id)
  end

  def chat_params
    params.require(:company_chat).permit(:res_id, :comment)
  end
end
