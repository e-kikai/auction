ActionMailer::Base.register_interceptor(MailInterceptor) if Rails.env.staging?
