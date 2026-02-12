class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  private

  def current_admin
    @current_admin ||= AdminUser.find_by(id: session[:admin_id]) if session[:admin_id]
  end
  helper_method :current_admin

  def require_admin
    unless current_admin
      redirect_to admin_login_path, alert: "Please log in to continue."
    end
  end

  def voter_name
    cookies.signed[:voter_name]
  end
  helper_method :voter_name
end
