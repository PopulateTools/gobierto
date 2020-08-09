class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  private

  def from
    APP_CONFIG[:email_config][:default_from]
  end

  def site_host
    @site.try(:domain) || ENV["HOST"]
  end

  def reply_to
    @site&.reply_to_email
  end
end
