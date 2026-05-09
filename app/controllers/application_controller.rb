class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token

  stale_when_importmap_changes
 
  before_action :require_login
 
  helper_method :current_user, :logged_in?, :admin?
 
  private
 
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
 
  def logged_in?
    current_user.present?
  end
 
  def admin?
    current_user&.admin?
  end
 
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Faça login para continuar."
    end
  end
 
  def require_admin
    unless admin?
      redirect_to root_path, alert: "Acesso restrito."
    end
  end
end