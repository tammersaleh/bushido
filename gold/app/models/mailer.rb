class Mailer < ActionMailer::Base
  def create_confirmation(user)
    @subject     = I18n.t 'actionmailer.create_confirmation', :default => 'Create confirmation'
    @from        = "none@example.com"
    @recipients  = user.email
    @body[:user] = user
  end

  def update_confirmation(user)
    @subject     = I18n.t 'actionmailer.update_confirmation', :default => 'Update e-mail confirmation'
    @from        = "none@example.com"
    @recipients  = user.email
    @body[:user] = user
  end

  def reset_password(user)
    @subject     = I18n.t 'actionmailer.reset_password', :default => 'Reset password'
    @from        = "none@example.com"
    @recipients  = user.email
    @body[:user] = user
  end

  def resend_confirmation(user)
    @subject     = I18n.t 'actionmailer.resend_confirmation', :default => 'Confirmation code'
    @from        = "none@example.com"
    @recipients  = user.email
    @body[:user] = user
  end

end

