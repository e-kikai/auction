class BidMailer < ApplicationMailer
  def bid_user(user, bid)
    @user = user
    @bid  = bid

    # mailto = Rails.env.production? ? @machine.company.contact_mail : @contact.mail

    mail(
      to:       user.email,
      subject:  "ものオク 入札確認 : #{@bid.product.name}"
    )
  end

  def bid_company(user, bid)
    @user = user
    @bid = bid

    mail(
      to:       user.email,
      subject:  "ものオク 入札されました : #{@bid.product.name}"
    )
  end

  def bid_rooser(user, bid)
    @user = user
    @bid = bid

    mail(
      to:       user.email,
      subject:  "ものオク 高値更新 : #{@bid.product.name}"
    )
  end
end
