class RegistrationsController < Devise::RegistrationsController
  def after_sign_up_path_for(resource)
    "/myauction/user/edit"
    # "/products/259"
  end

  def after_inactive_sign_up_path_for(resource)
    "/"
  end
end
