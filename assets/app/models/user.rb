class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_password_field = false
    config.validate_email_field = false
  end

  has_attached_file :photo, 
                    :storage => :s3, 
                    :bucket => "test-app",
                    :path => ":class/:id/:attachment/:style.:extension",
                    :default_url => "/images/default_:style_avatar.jpg",
                    :default_style => :small,
                    :styles => { :small => "64x64#", :medium => "128x128#" },
                    :s3_credentials => { :access_key_id     => S3_KEY, 
                                         :secret_access_key => S3_SECRET }

  validates_presence_of :password, :on => :create
  validates_confirmation_of :password, :if => :require_password?
  validates_presence_of :email
  validates_presence_of :name

  def to_s
    name
  end

  def destroy
    update_attributes!(:active => false)
  end
end

