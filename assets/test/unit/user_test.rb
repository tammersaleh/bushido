require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_db_column :active, :type => :boolean, :default => false

  should_have_db_index :email
  should_have_db_index :active
  should_have_db_index :perishable_token

  should_have_paperclip_field :photo

  should "be authentic" do
    assert !User.ancestors.map(&:to_s).grep(/Authlogic/).empty?
  end

  should "validate password confirmation with both set" do
    user = Factory.build(:user, :password => "foo", :password_confirmation => "bar")
    assert !user.valid?
    assert_match /confirmation/, user.errors.on(:password)
  end

  should "not update password on update if password isn't set" do
    user = Factory(:user)
    assert crypted_password = user.crypted_password
    user.password = ""
    user.password_confirmation = ""
    assert user.valid?, user.errors.full_messages
    assert_equal crypted_password, user.reload.crypted_password
  end

  should "return user's name on to_s" do
    assert_equal "Tammer Saleh", Factory(:user, :name => "Tammer Saleh").to_s
  end

  should "deactivate itself on destroy" do
    user = Factory(:user)
    assert user.active?
    user.destroy
    assert !user.reload.active?
  end

  should "send a confirmation email when saving an inactive user" do
    ActionMailer::Base.deliveries.clear
    user = Factory(:inactive_user)
    assert_sent_email { |e| e.to.first == user.email }
  end

  should_be_creatable_by("anyone") { nil }

  context "a new user" do
    subject { @user }
    setup { @user = User.new }

    should_validate_presence_of :email

    should "not validate the presence of name" do
      @user.save
      assert_nil @user.errors.on(:name)
    end

    should "not validate the presence of password" do
      @user.save
      assert_nil @user.errors.on(:password)
    end
  end

  context "an active user" do
    subject { @user }
    setup { @user = Factory(:user) }

    should "be returned by .active" do
      assert User.active.exists?(@user)
    end

    should_be_readable_by(   "anyone") { nil }

    should_be_editable_by(   "themselves") { @user }
    should_be_destroyable_by("themselves") { @user }

    should_not_be_editable_by(   "everyone")     { nil }
    should_not_be_destroyable_by("everyone")     { nil }
    should_not_be_editable_by(   "another user") { Factory(:user) }
    should_not_be_destroyable_by("another user") { Factory(:user) }
  end

  context "an inactive user" do
    setup { @user = Factory(:inactive_user) }

    should "not be returned by .active" do
      assert !User.active.exists?(@user)
    end

    context "that's set to active" do
      subject { @user }
      setup { @user.active = true }

      should_validate_presence_of :name

      should "require password" do
        @user.save
        assert @user.errors.on(:password).present?
      end
    end
  end
end
