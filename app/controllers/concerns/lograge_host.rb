module LogrageHost
  extend ActiveSupport::Concern

  # This will add request's host to lograge
  #
  # The address fields are read by config/initializers/lograge.rb. They tell
  # whether the client addresses rate limiting counts are the visitors' own or
  # the address of a proxy shared by a whole site.
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:remote_ip] = remote_ip
    payload[:ip] = request.ip
    payload[:x_forwarded_for] = request.headers["X-Forwarded-For"]
    payload[:cf_connecting_ip] = request.headers["CF-Connecting-IP"]
  end
end
