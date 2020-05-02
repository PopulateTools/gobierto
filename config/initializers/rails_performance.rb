RailsPerformance.setup do |config|
  config.redis    = Redis::Namespace.new("#{Rails.env}-rails-performance", redis: Redis.new)
  config.duration = 1.month

  config.debug    = false
  config.enabled  = ENV["RAILS_PERFORMANCE_ENABLED"]

  # protect your Performance Dashboard with HTTP BASIC password
  config.http_basic_authentication_enabled   = ENV["RAILS_PERFORMANCE_USERNAME"].present?
  config.http_basic_authentication_user_name = ENV["RAILS_PERFORMANCE_USERNAME"]
  config.http_basic_authentication_password  = ENV["RAILS_PERFORMANCE_PASSWORD"]

  # if you need an additional rules to check user permissions
  config.verify_access_proc = proc { |controller| true }
  # for example when you have `current_user`
  # config.verify_access_proc = proc { |controller| controller.current_user && controller.current_user.admin? }
end if defined?(RailsPerformance)
