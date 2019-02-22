class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "ものづくりオークション<info@mnok.net>"
  # layout 'mailer'
end

ActionMailer::Base.register_observer(EmailLogObserver.new)
