# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
  
    def new
      @role = params[:role] || "client"
      super
    end
  
    def create
        build_resource(sign_up_params)
      
        resource.role = sign_up_params[:role]
      
        if resource.save
          sign_up(resource_name, resource)
          redirect_to root_path, notice: "Welcome! You have signed up successfully."
        else
          flash[:alert] = resource.errors.full_messages.to_sentence
          redirect_to new_user_registration_path(role: resource.role)
        end
      end      
  
    protected
  
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :first_name, :last_name, :country])
    end
  end
  