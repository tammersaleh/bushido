class UsersController < InheritedResources::Base
  protects_restful_actions
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :require_self, :except => [:new, :create, :show]

  actions :new, :create, :show, :edit, :update

  def create
    create! do |success, failure|
      success.html { redirect_to root_url }
    end
  end
  
  private

  def require_self
    deny_access unless current_user == resource
  end
end
