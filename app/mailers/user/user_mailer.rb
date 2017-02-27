class User::UserMailer < ApplicationMailer
  def confirmation_instructions(user, site)
    @user = user
    @site = site

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t('.subject', site_name: @site.name)
    )
  end

  def reset_password_instructions(user, site)
    @user = user
    @site = site

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t('.subject')
    )
  end

  def welcome(user, site)
    @user = user
    @site = site

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: "Welcome to Gobierto"
    )
  end
end
