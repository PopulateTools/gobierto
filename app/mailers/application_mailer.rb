# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  private

  def from
    site_from || default_from
  end

  def site_from
    @site.presence && "#{@site.name} <#{APP_CONFIG["email_config"]["default_email"]}>"
  end

  def site_host
    @site.try(:domain) || ENV["HOST"]
  end

  def default_from
    APP_CONFIG["email_config"]["default_from"]
  end

  def default_reply_to
    APP_CONFIG["email_config"]["default_reply_to"]
  end
end
