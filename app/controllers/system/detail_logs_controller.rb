class System::DetailLogsController < System::ApplicationController
  include Exports

  def index
    @date = params[:date] ? Time.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now
    @detail_logs  = DetailLog.includes(:user, product: [:category, :max_bid, :user]).where(created_at: @date.beginning_of_month..@date.end_of_month).order(created_at: :desc)

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

    @columns_ekikai = %w|マシンライフ 全機連 e-kikai 電子入札| # e-kikaiサイト郡
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

  ### ユーザ別ログ出録 ###
  def search
    ### 日付設定 ###
    @date_start = (params[:date_start] || Date.today - 1.week).to_date
    @date_end   = (params[:date_end] || Date.today).to_date
    where   = {created_at: @date_start.beginning_of_day..@date_end.end_of_day}
    reorder = {created_at: :desc}

    ### 商品指定 ###
    if params[:product_id].present?
      @product = Product.find(params[:product_id])
      where[:product_id] = params[:product_id]
    end

    ### ユーザ指定 ###
    logs = if params[:user_id].present?
      if params[:user_id].strip =~ /^[0-9]+$/
        ### ユーザID指定 ###
        @user = User.find(params[:user_id])

        # IPからユーザ推測
        ips =  DetailLog.where(user_id: params[:user_id]).distinct.pluck(:ip)
        ips += SearchLog.where(user_id: params[:user_id]).distinct.pluck(:ip)
        ips += ToppageLog.where(user_id: params[:user_id]).distinct.pluck(:ip)
        ips << @user.last_sign_in_ip.to_s
        ips << @user.current_sign_in_ip.to_s

        user_where = ["(user_id = ? OR (user_id IS NULL AND ip IN (?)))", params[:user_id], ips.uniq]

        # ログデータ取得・結合
        @datail_logs  = DetailLog.includes(:user, :product).where(where).where(user_where)
        @search_logs  = SearchLog.includes(:user, :category, :company, :search, :nitamono_product).where(where).where(user_where)
        @toppage_logs = ToppageLog.includes(:user).where(where).where(user_where)

        @watches      = Watch.includes(:user, product:[ :category]).where(where).where(user_id:params[:user_id])
        @bids         = Bid.includes(:user, product:[ :category] ).where(where).where(user_id:params[:user_id])

        @follows      = Follow.includes(:user, :to_user).where(where).where(user_id:params[:user_id])
        @trades       = Trade.includes(:user, product:[ :category]).where(where).where(user_id:params[:user_id])

        [] + @datail_logs + @search_logs + @toppage_logs + @watches + @bids + @follows + @trades
      else
        ### IP指定 ###
        where[:ip] = params[:user_id]

        # ログデータ取得・結合
        @datail_logs  = DetailLog.includes(:user, :product).where(where)
        @search_logs  = SearchLog.includes(:user, :category, :company, :search, :nitamono_product).where(where)
        @toppage_logs = ToppageLog.includes(:user).where(where)

        [] + @datail_logs + @search_logs + @toppage_logs
      end
    else
      ### ユーザ指定なし ###
      ### IP検索用テーブル ###
      @iptable = DetailLog.group(:ip).where.not(ip: nil, user_id:nil).maximum(:user_id)
      @iptable.merge! SearchLog.group(:ip).where.not(ip: nil, user_id:nil).maximum(:user_id)
      @iptable.merge! ToppageLog.group(:ip).where.not(ip: nil, user_id:nil).maximum(:user_id)

      ### IP類推用ユーザテーブル ###
      @users = User.all.group(:id)

      # ログデータ取得・結合
      @datail_logs  = DetailLog.includes(:user, :product).where(where)
      @search_logs  = SearchLog.includes(:user, :category, :company, :search, :nitamono_product).where(where)
      @toppage_logs = ToppageLog.includes(:user).where(where)

      @watches      = Watch.includes(:user, product:[ :category]).where(where)
      @bids         = Bid.includes(:user, product:[ :category] ).where(where)

      @follows      = Follow.includes(:user, :to_user).where(where)
      @trades       = Trade.includes(:user, product:[ :category]).where(where)

      [] + @datail_logs + @search_logs + @toppage_logs + @watches + @bids + @follows + @trades
    end

    ### ソート ###
    logs = logs.sort_by { |lo| lo.created_at }.reverse

    ### 事前整形 ###
    @relogs = logs .map do |lo|
      klass = case lo.class.to_s
      when "DetailLog";  ["詳細",           "glyphicon-gift",             "#FF9300"]
      when "SearchLog";  ["検索",           "glyphicon-search",           "#0433FF"]
      when "ToppageLog"; ["トップページ",   "glyphicon-home",             "#AA7942"]
      when "Watch";      ["ウォッチリスト", "glyphicon-star",             "#EE0"]
      when "Follow";     ["フォロー",       "glyphicon-heart",            "#D00"]
      when "Bid";        ["入札",           "glyphicon-pencil",           "#942192"]
      when "Trade";      ["問合せ・取引",   "glyphicon-comment",          "#3c763d"]
      else;              [lo.class,         "glyphicon-exclamation-sign", "#919191"]
      end

      ### 内容詳細 ###
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
          con << "新着: #{$1}"    if lo[:path].present? && lo[:path] =~ /news\/([0-9-]+)/
          con << "出品中を表示"   if lo[:path].present? && lo[:path] =~ /success\=start/
          con << "落札価格を表示" if lo[:path].present? && lo[:path] =~ /success\=success/
        end
      end

      # IPからユーザを推測
      ip_guess, user = if lo[:user_id].present?
        [false, lo&.user]
      elsif @user.present?
        [true, @user]
      elsif @iptable[lo[:ip].to_s].present? && @users[@iptable[lo[:ip]]].present?
        [true, @users[@iptable[lo[:ip]]]]
      end

      {
        created_at:   lo.created_at,
        klass:        klass,
        ip:           lo[:ip],
        host:         lo[:host],

        ip_guess:     ip_guess,
        user:         user,

        product:      (lo[:product_id].present? && lo.product) ? lo.product : nil,

        page:         lo[:page],
        con:          con,
        referer:      lo[:referer],
        ref:          lo[:referer].present? ? URI.unescape(lo.link_source) : "",
        r:            lo[:r],
      }
    end

    respond_to do |format|
      format.html {
        ### ページャ ###
        @prelogs = Kaminari.paginate_array(@relogs, total_count: @relogs.length).page(params[:page]).per(100)
      }
      format.csv {
        export_csv "logs_search_#{params[:user_id]}.csv"
      }
    end

  end
end
