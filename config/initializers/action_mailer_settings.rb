# frozen_string_literal: true

if Rails.application.secrets.mailer_delivery_method == "ses"
  Rails.application.config.action_mailer.delivery_method = :ses

  ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                         access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID") { "" },
                                         secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY") { "" },
                                         server: "email.eu-west-1.amazonaws.com",
                                         region: 'eu-west-1',
                                         signature_version: 4

elsif Rails.application.secrets.mailer_delivery_method == "smtp"
  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.smtp_settings = Rails.application.secrets.mailer_smtp_settings.compact.symbolize_keys

elsif Rails.application.secrets.mailer_delivery_method == "webservice"
  Rails.application.config.action_mailer.delivery_method = :webservice
  # The delivery class should be configured in an engine
end
