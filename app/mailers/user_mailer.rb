class UserMailer < ActionMailer::Base
  default from: "noreply@refactr.it"

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "Welcome to refactr.it")
  end
end
