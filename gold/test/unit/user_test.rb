require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_db_column :active, :type => :boolean, :default => true

  should_have_db_index :email
  should_have_db_index :active
  should_have_db_index :perishable_token

  should_validate_presence_of :email
  should_validate_presence_of :password
  should_validate_presence_of :name
  should_have_attached_file :photo

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
    crypted_password = user.crypted_password
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
end
