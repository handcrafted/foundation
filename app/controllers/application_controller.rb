# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :signed_in?, :signed_out?
  before_filter :find_site

  def signed_in?
    ! current_user.nil?
  end
  
  def signed_out?
    current_user.nil?
  end

  private
  
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be signed in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end
    
    def require_admin
      unless current_user && current_user.admin?
        store_location
        flash[:notice] = "You must be an admin to access this page"
        redirect_to account_url if signed_in?
        redirect_to signin_url if signed_out?
        return false
      end
    end
    
    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be signed out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def find_site
      @site ||= SiteSetting.find(:first)
    end
    
end
