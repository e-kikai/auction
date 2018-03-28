class MailInterceptor
  def self.delivering_email(message)
    message.to = "bata44883@gmail.com"
    message.subject.insert(0, "[Staging]")
  end
end
