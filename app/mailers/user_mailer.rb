class UserMailer < ActionMailer::Base
  default from: "mailer@multgroupevents.com"
  @site_name = CONFIG[:email_site_name] || "MultiGroup Events"

  def email_validation_token(user)
    @user = user
#    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Email Validation Code')
  end

  def changed_email_validation_token(user)
    @user = user
#    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Changed Email Validation Code')
  end

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def password_reset(user, is_new=false)
    @user = user
    mail :to => user.email, :subject => "Password Reset", :is_new => is_new
  end

  def password_set(user)
    @user = user
    mail :to => user.email, :subject => "Set Password"
  end
end
