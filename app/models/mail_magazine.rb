# class MailMagazine
#   attr_accessor :mailchimp

#   def initialize
#     @mailchimp = Mailchimp::API.new(Rails.application.secrets.mailchimp_api_key)

#     @list_id   = Rails.application.secrets.mailchimp_list_id
#   end

#   # リストの情報を取得する
#   def fetch_mailing_list
#     @mailchimp.lists.list
#   end

#   # リストに対象のメールアドレスがあるか？
#   def member?(email)
#     result = @mailchimp.lists.member_info(@list_id, [{email: email}])["success_count"]
#     result > 0
#   end

#   # リストに追加
#   def add_member(user, email)
#     @mailchimp.lists.subscribe(
#       # @list_id, {email: email}, {USER_ID: user.id, NAME: user.name, COMPANY: user.company}, "html", false)
#       @list_id, {email: email}, {USER_ID: user.id, NAME: user.name, COMPANY: user.company, SELLER: (user.seller? ? :company : :user)}, "html", false)
#   end

#   # リストから削除
#   def remove_member(email)
#     @mailchimp.lists.unsubscribe(@list_id, {email: email}, false, false, false)
#   end
# end

class MailMagazine
  attr_accessor :mailchimp

  MAILCHIMP_URL = "https://us8.api.mailchimp.com/3.0"

  def initialize
    # @mailchimp = Mailchimp::API.new(Rails.application.secrets.mailchimp_api_key)
    @list_id   = Rails.application.secrets.mailchimp_list_id

    url = URI.parse(MAILCHIMP_URL)

    @http_client = Net::HTTP.new(url.host, url.port)
    @http_client.use_ssl = true
  end

  # リストの情報を取得する
  # def fetch_mailing_list
  #   @mailchimp.lists.list
  # end

  # リストに対象のメールアドレスがあるか？
  # def member?(email)
  #   result = @mailchimp.lists.member_info(@list_id, [{email: email}])["success_count"]
  #   result > 0
  # end

  # リストに追加
  def add_member(user, email)
    # Rails.logger.debug "########## add_member #{email}"

    ### 応急処置
    # @mailchimp.lists.subscribe(
    #   # @list_id, {email: email}, {USER_ID: user.id, NAME: user.name, COMPANY: user.company}, "html", false)
    #   @list_id, {email: email}, {USER_ID: user.id, NAME: user.name, COMPANY: user.company, SELLER: (user.seller? ? :company : :user)}, "html", false)

    ### 新処理 ###
    query = {USER_ID: user.id, NAME: user.name, COMPANY: user.company, SELLER: (user.seller? ? :company : :user)}

    url = "#{MAILCHIMP_URL}/lists/#{@list_id}/members/#{Digest::MD5.hexdigest(email)}"

    # query ={NAME: "testtest", COMPANY: "テスト"}
    # email = "bata44883+d@gmail.com"

    data = {
      email_address: email,
      status: :subscribed,
      merge_fields: query,
    }

    req = Net::HTTP::Put.new(url, {'Content-Type' => 'application/json'})
    req.basic_auth("anystring", Rails.application.secrets.mailchimp_api_key)
    req.body = data.to_json

    res = @http_client.request(req)

    # json = JSON.parse(res.body)
  end

  # リストから削除
  def remove_member(email)
    # Rails.logger.debug "########## remove_member #{email}"
    # @mailchimp.lists.unsubscribe(@list_id, {email: email}, false, false, false)

    ### 新処理 ###
    # email ="bata44883+c@gmail.com"

    url = "#{MAILCHIMP_URL}/lists/#{@list_id}/members/#{Digest::MD5.hexdigest(email)}"

    data = {
      status: :unsubscribed
    }

    req = Net::HTTP::Put.new(url, {'Content-Type' => 'application/json'})
    req.basic_auth("anystring", Rails.application.secrets.mailchimp_api_key)
    req.body = data.to_json

    res = @http_client.request(req)
  end
end
