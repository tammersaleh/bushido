require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_many :notes

  should_have_db_column :active, :type => :boolean, :default => true

  should_validate_presence_of :email
  should_validate_presence_of :password
  should_validate_presence_of :name, :company_name, :job_title
  should_validate_presence_of :user_type
  should_allow_values_for :user_type, "journalist", "company representative", "administrator"
  should_not_allow_values_for :user_type, "something else"

  should_not_allow_mass_assignment_of :user_type

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

  should "know if it's a journalist" do
    assert Factory(:journalist).journalist?
    assert !Factory(:journalist).company_representative?
    assert !Factory(:journalist).administrator?
  end

  should "know if it's a company representative" do
    assert Factory(:company_representative).company_representative?
    assert !Factory(:company_representative).administrator?
    assert !Factory(:company_representative).journalist?
  end

  should "know if it's an administrator" do
    assert Factory(:administrator).administrator?
    assert !Factory(:administrator).journalist?
    assert !Factory(:administrator).company_representative?
  end

  context "given users of each type" do
    setup do
      Factory(:journalist)
      Factory(:company_representative)
      Factory(:administrator)
    end

    User::AllUserTypes.each do |user_type|
      should "return #{user_type} users on .user_type(#{user_type})" do
        assert_named_scope(User.all, User.user_type(user_type)) { |u| u.user_type == user_type }
      end
    end
  end

  context "given users from different companies" do
    setup do
      Factory(:journalist,             :company_name => "NBC")
      Factory(:company_representative, :company_name => "ABC")
      Factory(:company_representative, :company_name => "CBS")
    end

    %w(NBC CBS ABC).each do |company_name|
      should "return users from #{company_name} users on .company(#{company_name})" do
        assert_named_scope(User.all, User.company(company_name)) { |u| u.company_name == company_name }
      end
    end

    should "return names of all companies on .all_company_names" do
      assert_same_elements %w(NBC ABC CBS), User.all_company_names
    end
  end
end
