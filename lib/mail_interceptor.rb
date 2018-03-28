class MailInterceptor
  def self.delivering_email(message)
    message.to      = "bata44883@gmail.com"
    message.subject = "[Staging] #{message.subject}"
  end
end
