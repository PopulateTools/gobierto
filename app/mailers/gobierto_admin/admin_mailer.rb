module GobiertoAdmin
  class AdminMailer < ApplicationMailer
    def confirmation_instructions(admin)
      @admin = admin

      mail(
        from: default_from,
        reply_to: default_reply_to,
        to: @admin.email,
        subject: t('.subject')
      )
    end

    def invitation_instructions(admin)
      @admin = admin

      mail(
        from: default_from,
        reply_to: default_reply_to,
        to: @admin.email,
        subject: t(".subject")
      )
    end

    def reset_password_instructions(admin)
      @admin = admin

      mail(
        from: default_from,
        reply_to: default_reply_to,
        to: @admin.email,
        subject: t('.subject')
      )
    end
  end
end
