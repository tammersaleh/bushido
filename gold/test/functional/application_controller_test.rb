require 'test_helper'

class FooController < ApplicationController
  skip_before_filter :require_user, :only => :unprotected_foo

  def beta_password_required?
    true
  end

  def foo
    render :text => 'Success', :layout => "application"
  end

  def unprotected_foo
    render :text => 'Success', :layout => "application"
  end
end

class ApplicationControllerTest < ActionController::TestCase
  tests FooController

  setup do
    ActionController::Routing::Routes.add_named_route :foo, '/foo', 
                                                      :controller => 'foo', 
                                                      :action => 'foo'
    ActionController::Routing::Routes.add_named_route :unprotected_foo, 
                                                      '/unprotected_foo', 
                                                      :controller => 'foo', 
                                                      :action => 'unprotected_foo'
  end

  context "when the beta_access cookie is in place" do
    setup { @request.cookies["beta_access"] = "yep" }

    as_a_visitor do
      context "getting a page" do
        setup { get :foo }

        should_redirect_to("the login page") { new_user_session_url }
        should_set_the_flash_to /must be logged in/i
      end

      context "getting a public page" do
        setup { get :unprotected_foo }

        should "not try to include the user's name" do
          assert_no_match(/Hello/, @response.body)
        end

        should "not present a logout link" do
          assert_no_match(/Logout/, @response.body)
        end
      end
    end

    as_a_journalist do
      context "the layout" do
        setup { get :foo }

        should "include the user's name" do
          assert_match(/#{@logged_in_user.name}/, @response.body)
        end

        should "present the user with a logout link" do
          assert_select 'a[href=?]', user_session_url, "Logout"
        end

        should "present a close sidebar link" do
          assert_select 'a[id=?]', "close_sidebar"
        end
      end
    end
  end

  context "when the beta_access cookie is not in place" do
    setup { cookies["beta_access"] = nil }
    as_a_visitor do
      context "getting a page" do
        setup { get :foo }

        should_redirect_to("the beta login page") { new_beta_session_url }
        should_set_the_flash_to /beta/i
      end
    end

    as_a_journalist do
      context "getting a page" do
        setup { get :foo }

        should_redirect_to("the beta login page") { new_beta_session_url }
        should_set_the_flash_to /beta/i
      end
    end
  end
end
