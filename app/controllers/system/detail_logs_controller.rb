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

    @columns_ekikai = %w|マシンライフ 全機連 e-kikai 電子入札システム DST| # e-kikaiサイト郡
    @columns_ads    = %w|マシンライフ e-kikai| # 広告枠
    @columns_search = %w|Google Yahoo bing 百度 Twitter FB YouTube 広告 (不明)| # 検索・SNS

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

  def search
    @date_start = (params[:date_start] || Date.today - 1.week).to_date
    @date_end   = (params[:date_end] || Date.today).to_date

    where    = {created_at: @date_start.beginning_of_day..@date_end.end_of_day, user_id: 9999999999}
    ip_where = {created_at: @date_start.beginning_of_day..@date_end.end_of_day}

    if params[:user_id].present?
      ips = if params[:user_id].strip =~ /^[0-9]+$/
        @user           = User.find(params[:user_id])
        where[:user_id] = params[:user_id]

        # IPからユーザ推測
        ips =  DetailLog.where(user_id: params[:user_id]).distinct.pluck(:ip)
        ips += SearchLog.where(user_id: params[:user_id]).distinct.pluck(:ip)
        ips += ToppageLog.where(user_id: params[:user_id]).distinct.pluck(:ip)
        ips << @user.last_sign_in_ip.to_s
        ips << @user.current_sign_in_ip.to_s

        ips.uniq
      else
        params[:user_id]
      end

      ip_where[:ip] = ips
    end

    product_where = {}
    if params[:product_id].present?
      @product = Product.find(params[:product_id])
      product_where[:product_id] = params[:product_id]
    end

    reorder = {created_at: :desc}

    @datail_logs  = DetailLog.includes(:user, :product).where(ip_where).where(product_where).reorder(reorder)
    @search_logs  = SearchLog.includes(:user, :category, :company, :search, :nitamono_product).where(ip_where).reorder(reorder)
    @toppage_logs = ToppageLog.includes(:user).where(ip_where).reorder(reorder)

    @watches      = Watch.includes(:user, :product).where(where).reorder(reorder)
    @bids         = Bid.includes(:user, :product).where(where).reorder(reorder)

    @follows      = Follow.includes(:user, :to_user).where(where).reorder(reorder)
    @trades       = Trade.includes(:user, :product).where(where).reorder(reorder)

    logs = [] + @datail_logs + @search_logs + @toppage_logs + @watches + @bids
    @logs = logs.sort_by { |lo| lo.created_at }.reverse


    @product = Product.find(params[:product_id]) if params[:product_id]

    ### 事前整形 ###
    @relogs = @logs .map do |lo|

      klass = case lo.class.to_s
      when "DetailLog";  ["詳細", "glyphicon-gift", "#FF9300"]
      when "SearchLog";  ["検索", "glyphicon-search", "#0433FF"]
      when "ToppageLog"; ["トップページ", "glyphicon-home", "#AA7942"]
      when "Watch";      ["ウォッチリスト", "glyphicon-star", "#EE0"]
      when "Follow";     ["フォロー", "glyphicon-heart", "#D00"]
      when "Bid";        ["入札", "glyphicon-pencil", "#942192"]
      when "Trade";      ["問合せ・取引", "glyphicon-comment", "#3c763d"]
      else; [lo.class, "glyphicon-exclamation-sign", "#919191"]
      end

      con = []
      if lo[:product_id].present? && lo.product
        con << "[#{lo.product.state}]" unless lo.product.state == "中古"

        con << "即売:#{lo.product.prompt_dicision_price}円" if lo.product.prompt_dicision_price

        con << "終了済" if lo.product.dulation_end < lo.created_at
      end


      if lo.class.to_s == "SearchLog"
        if lo[:search_id].present? && lo.search
          con << "特集: #{lo.search.name}"
        else
          con << "キーワード: #{lo.keywords}"                  if lo[:keywords].present?
          con << "カテゴリ: #{lo.category.name}"               if lo[:category_id].present? && lo.category
          con << "出品会社: #{lo.company.company_remove_kabu}" if lo[:company_id].present? && lo.company
          con << "すべてのカテゴリ" if con.blank? && lo[:path].present? && lo[:path] =~ /products($|\?)/
          if lo[:nitamono_product_id].present? && lo.nitamono_product
            con <<  "似たものサーチ: [#{lo.nitamono_product_id}] #{lo.nitamono_product.name}"
          end
          con << "新着: #{$1}"      if lo[:path].present? && lo[:path] =~ /news\/([0-9-]+)/
          con << "出品中を表示"       if lo[:path].present? && lo[:path] =~ /success\=start/
          con << "落札価格を表示" if lo[:path].present? && lo[:path] =~ /success\=success/
        end
      end

      {
        created_at:   lo.created_at,
        klass:        klass,
        ip:           lo[:ip].presence || "",
        user_id:      lo[:user_id].presence || "",
        user_name:    lo[:user_id].present? && lo.user ? "#{lo.user.company} #{lo.user.name}" : "",

        ip_guess:     (@user.present? && lo[:user_id].blank?) ? true : false,

        product_id:   lo[:product_id].presence || "",
        product_name: (lo[:product_id].present? && lo.product) ? lo.product.name : "",

        max_price:    (lo[:product_id].present? && lo.product) ? lo.product.max_price : "",
        amount:       lo[:amount].presence || "",
        bids_count:    (lo[:bids_count].present? && lo.product) ? lo.product.bids_count : "",

        page:         lo[:page].presence || "",
        con:          con,
        ref:          lo[:referer].present? ? URI.unescape(lo.link_source) : "",
      }
    end

    respond_to do |format|
      format.html
      format.csv {
        export_csv "logs_search_#{params[:user_id]}.csv"
      }
    end

  end
end
