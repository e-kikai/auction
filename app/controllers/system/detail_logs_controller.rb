class System::DetailLogsController < System::ApplicationController
  include Exports

  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @detail_logs  = DetailLog.includes(:product, :user).where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)

    respond_to do |format|
      format.html {
        @pdetail_logs = @detail_logs.page(params[:page]).per(500)
      }
      format.csv { export_csv "detail_logs_#{@date.strftime('%Y_%m')}.csv" }
    end
  end

  def monthly
    @date    = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now.to_date

    startd = @date.beginning_of_month
    endd   = @date.end_of_month
    days   = startd..endd
    where_ref  = "(referer NOT LIKE 'https://www.mnok.net%' OR referer LIKE 'https://www.mnok.net/products/ads%')"
    where_date = ["DATE(created_at) BETWEEN ? AND ?", startd, endd]
    group_by   = ["DATE(created_at)", :referer, :r]

    @detail_logs  = DetailLog.where(where_date).where(where_ref).group(group_by).count()
    @toppage_logs = ToppageLog.where(where_date).where(where_ref).group(group_by).count()

    @columns_ekikai = %w|マシンライフ 全機連 e-kikai 電子入札システム デッドストック| # e-kikaiサイト郡
    @columns_ads    = %w|マシンライフ e-kikai| # 広告枠
    @columns_search = %w|Google Yahoo Twitter Facebook bing YouTube (不明)| # 検索・SNS

    @sellers_url = User.where(seller: true).where.not(url: "").pluck(:url) # 出品会社サイト
    @urls = @sellers_url.map { |url| url =~ /\/\/(.*?)(\/|$)/ ? $1 : nil }.compact
    @urls << "kkmt.co.jp"

    @total = Hash.new()
    days.each do |day|
      @total[day] = {
        search:      @columns_search.map { |co| [co, 0] }.to_h,
        ads:         @columns_ads.map { |co| [co, 0] }.to_h,
        ekikai:      @columns_ekikai.map { |co| [co, 0] }.to_h,
        sellers:     0,
        others:      0,
        mailchimp:   0,
        remind_mail: 0,
        alert_mail:  0,
        trade_mail:  0,
        others_urls: [],
      }
    end

    logs = @detail_logs.merge(@toppage_logs)

    logs.each do |keys, val|
      li  = DetailLog.link_source(keys[2], keys[1])
      day = keys[0].to_date

      if li.in?(@columns_search)
        # 検索・SNS
        @total[day][:search][li] += val
      elsif li.include?("ads")
        # 広告枠
        @columns_ads.each do |site|
          if li.include?(site)
            @total[day][:ads][site] += val
          end
        end
      elsif li.include?("Mailchimp")
        # Mailchimp
        @total[day][:mailchimp] += val
      elsif li.include?("メール") && li.include?("新着")
        # 新着メール
        @total[day][:alert_mail] += val
      elsif li.include?("メール") && li.include?("通知")
        # 通知メール
        @total[day][:trade_mail] += val
      elsif li.include?("メール") && li.include?("リマインダ")
        # リマインダ
        @total[day][:remind_mail] += val
      elsif li.in?(@urls)
        # 出品会社サイト
        @total[day][:sellers] += val

      elsif keys[1] !~ /mnok\.net/
        # e-kikaiメンバー
        tmp = false
        @columns_ekikai.each do |col|
          if li.include?(col)
            @total[day][:ekikai][col] += val
            tmp = true
          end
        end

        # その他
        if tmp == false
          @total[day][:others_urls] << keys[1]
          @total[day][:others] += val
        end
      end

    end
  end
end
