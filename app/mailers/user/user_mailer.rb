class User::UserMailer < ApplicationMailer
  def confirmation_instructions(user, site)
    @user = user
    @site = site

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: "Confirmation instructions"
    )
  end

  def reset_password_instructions(user, site)
    @user = user
    @site = site

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: "Reset password instructions"
    )
  end
end
