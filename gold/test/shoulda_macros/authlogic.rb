require "authlogic/test_case"

class ActionController::TestCase
  setup :activate_authlogic

  def self.as_a_visitor(&blk)
    context "As a visitor" do
      setup { UserSession.find && UserSession.find.destroy }
      merge_block(&blk)
    end
  end

  def self.as_a_journalist(&blk)
    context "As a logged in journalist" do
      setup do
        @logged_in_user = Factory(:journalist)
        UserSession.create(@logged_in_user)
      end
      merge_block(&blk)
    end
  end

  def self.as_a_company_representative(&blk)
    context "As a logged in company representative" do
      setup do
        @logged_in_user = Factory(:company_representative)
        UserSession.create(@logged_in_user)
      end
      merge_block(&blk)
    end
  end

  def self.as_an_administrator(&blk)
    context "As a logged in administrator" do
      setup do
        @logged_in_user = Factory(:administrator)
        UserSession.create(@logged_in_user)
      end
      merge_block(&blk)
    end
  end

  def self.should_be_denied_on(code, opts = {})
    context "should be denied on #{code.inspect}" do
      setup { eval code }
      should_set_the_flash_to(opts[:flash] || /access/i)
      should_respond_with :redirect
    end
  end
end
