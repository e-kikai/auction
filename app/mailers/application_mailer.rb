class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: 'ものオク<info@mnok.net>'
  # layout 'mailer'
end
