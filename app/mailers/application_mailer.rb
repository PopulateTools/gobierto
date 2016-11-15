class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  private

  def default_from
    APP_CONFIG["email_config"]["default_from"]
  end

  def default_reply_to
    APP_CONFIG["email_config"]["default_reply_to"]
  end
end
