class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  
  default from: 'info@mnok.net'
  # layout 'mailer'
end
