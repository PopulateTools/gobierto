class Admin::AdminMailer < ApplicationMailer
  def confirmation_instructions(admin)
    @admin = admin

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @admin.email,
      subject: "[Admin] Confirmation instructions"
    )
  end

  def invitation_instructions(admin)
    @admin = admin

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @admin.email,
      subject: "[Admin] Invitation instructions"
    )
  end

  def reset_password_instructions(admin)
    @admin = admin

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @admin.email,
      subject: "[Admin] Reset password instructions"
    )
  end
end
