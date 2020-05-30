class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :flash_clear

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to request.referrer
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:
      [:first_name, :last_name, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: 
      [:first_name, :last_name, :avatar,:remove_avatar])
  end

  private
  def flash_clear
    flash.clear()
  end

end
