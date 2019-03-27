# frozen_string_literal: true

module GobiertoAdmin
  class AdminMailer < ApplicationMailer
    def invitation_instructions(admin)
      @admin = admin
      @site = admin.sites.first
      @site_host = site_host

      mail(
        from: from,
        reply_to: default_reply_to,
        to: @admin.email,
        subject: t(".subject")
      )
    end

    def reset_password_instructions(admin)
      @admin = admin
      @site = admin.sites.first
      @site_host = site_host

      mail(
        from: from,
        reply_to: default_reply_to,
        to: @admin.email,
        subject: t(".subject")
      )
    end
  end
end
