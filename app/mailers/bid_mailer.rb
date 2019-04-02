class BidMailer < ApplicationMailer
  # ユーザ、入札
  def bid_user(user, bid)
    @user = user
    @bid  = bid

    mail(to: user.email, subject: "ものオク 入札確認 : #{@bid.product.name}")
  end

  # 以前の最高入札者
  def bid_loser(user, product)
    @user    = user
    @product = product

    mail(to: user.email, subject: "ものオク 高値更新 : #{@product.name}")
  end

  # 出品会社、入札
  def bid_company(product)
    @product = product

    mail(to: product.user.email, subject: "ものオク 入札通知 : #{@product.code} #{@product.name}")
  end

  # ユーザ、落札
  def success_user(user, product)
    @user    = user
    @product = product

    mail(to: user.email, subject: "ものオク 落札できました : #{@product.name}")
  end

  # 出品会社、落札
  def success_company(product)
    @product = product

    mail(to: product.user.email, subject: "ものオク 落札通知 : #{@product.code} #{@product.name}")
  end

  # ユーザ、取引
  def trade_user(trade)
    @trade   = trade
    @user    = trade.product.max_bid.user
    @product = trade.product

    mail(to: @user.email, subject: "ものオク 出品会社からの取引メッセージ : #{@trade.product.name}")
  end

  # 出品会社、取引
  def trade_company(trade)
    @trade = trade
    @product = trade.product

    mail(to: trade.product.user.email, subject: "ものオク ユーザからの取引通知 : #{@trade.product.code} #{@trade.product.name}")
  end

  # 出品会社、評価
  def star_company(product)
    @product = product

    mail(to: product.user.email, subject: "ものオク ユーザからの評価通知 : #{@product.code} #{@product.name}")
  end

  # キャンセル
  def cancel_user(user, product)
    @user    = user
    @product = product

    mail(to: user.email, subject: "ものオク 出品キャンセルのお知らせ : #{@product.name}")
  end

  # ウォッチリマインダ
  def reminder(user, product)
    @user    = user
    @product = product

    mail(to: user.email, subject: "ものオク まもなく終了 : #{@product.name}")
  end

  # 新着アラート
  def news(alert)
    @alert = alert

    mail(to: alert.user.email, subject: "ものオク 新着情報 : #{@alert.name}")
  end

  # ウォッチ新着
  def watch_news(user, products)
    @user     = user
    @products = products

    mail(to: user.email, subject: "ものオク おすすめ新着情報")
  end

  # チラシ
  def flyer(user)
    mail(to: user.email, subject: "ものづくりオークション 新着商品 続々追加中！")
  end

  # 週間新着メール
  def news_week(user, date, products, count)
    @date     = date
    @products = products
    @count    = count

    mail(to: user.email, subject: "ものづくりオークション 今週の新着商品情報 (#{(@date - 6.day).strftime("%Y/%-m/%-d")} 〜 #{@date.strftime("%-m/%-d")})")
  end

end
