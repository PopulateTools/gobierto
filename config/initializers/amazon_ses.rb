ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => ENV.fetch("AWS_ACCESS_KEY_ID") { "" },
  :secret_access_key => ENV.fetch("AWS_SECRET_ACCESS_KEY") { "" },
  :server => 'email.eu-west-1.amazonaws.com'
