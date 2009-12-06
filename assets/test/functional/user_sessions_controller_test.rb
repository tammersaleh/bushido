require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  as_a_visitor do
    context "on GET to /login" do
      setup { get :new }
      should_render_template :new
      should_not_set_the_flash
    end

    context "on POST to /user_session/create with good creds" do
      setup do
        @user = Factory(:user, :name => "Bob", :password => "foobar")
        post :create, :user_session => { :email => @user.email, :password => "foobar" }
      end
      should_redirect_to("homepage") { root_url }
      should_set_the_flash_to(/welcome, bob/i)
    end

    context "on POST to /user_session/create with bad creds" do
      setup do
        @user = Factory(:user, :password => "foobar")
        post :create, :user_session => { :email => @user.email, :password => "bad" }
      end
      should_render_template :new
      should_not_set_the_flash
    end

    context "on POST to /user_session/create with creds for inactive user" do
      setup do
        @user = Factory(:user, :name => "Bob", :password => "foobar", :active => false)
        post :create, :user_session => { :email => @user.email, :password => "foobar" }
      end
      should_render_template :new
      should_not_set_the_flash
    end

    context "on delete to /logout" do
      setup { delete :destroy }
      should_be_denied_as_visitor
    end
  end

  as_a_logged_in_user do
    context "on DELETE to /user_session" do
      setup { delete :destroy }

      should_redirect_to("sign in page") { login_url }
      should_set_the_flash_to /good bye/i
      should "log the user out" do
        assert_nil UserSession.find
      end
    end
  end
end
