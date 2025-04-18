# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    super
  end

  # Override the create method to handle sign-in logic
  def create
    super
  end

  # Override the destroy method to handle sign-out logic
  def destroy
    super
  end

  # After sign-in, redirect to the home page
  def after_sign_in_path_for(resource)
    root_path
  end

  # After sign-out, redirect to the sign-in page
  def after_sign_out_path_for(resource)
    login_user_path
  end

  # If you need extra params during sign-in, you can uncomment and customize this method
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
