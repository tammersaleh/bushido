# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  include HoptoadNotifier::Catcher

  filter_parameter_logging :password, :password_confirmation

  before_filter :require_user

private
 
  def require_no_user
    if current_user
      deny_access :redirect_to => root_url,
                  :flash       => "You must be logged out to access this page."
    end
  end

  def interpolation_options
    { :resource_name => resource.to_s }
  end
end
