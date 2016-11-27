module GobiertoAdmin
  class UserMailer < ApplicationMailer
    def confirmation_instructions(user, site)
      @user = user
      @site = site

      mail(
        from: default_from,
        reply_to: default_reply_to,
        to: @user.email,
        subject: "[Admin] Confirmation instructions"
      )
    end

    def reset_password_instructions(user, site)
      @user = user
      @site = site

      mail(
        from: default_from,
        reply_to: default_reply_to,
        to: @user.email,
        subject: "[Admin] Reset password instructions"
      )
    end

    def welcome(user, site)
      @user = user
      @site = site

      mail(
        from: default_from,
        reply_to: default_reply_to,
        to: @user.email,
        subject: "[Admin] Welcome to Gobierto"
      )
    end
  end
end
