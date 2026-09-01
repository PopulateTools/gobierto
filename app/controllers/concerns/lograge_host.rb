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
    payload[:remote_ip] = resolved_remote_ip
    payload[:ip] = request.ip
    payload[:x_forwarded_for] = request.headers["X-Forwarded-For"]
    payload[:cf_connecting_ip] = request.headers["CF-Connecting-IP"]
  end

  private

  # Contradictory Client-IP and X-Forwarded-For headers are supplied by the
  # client, and append_info_to_payload runs in the ensure of process_action:
  # letting the raise through turns a rendered response into a 500. The other
  # address fields still record what the client sent.
  def resolved_remote_ip
    remote_ip
  rescue ActionDispatch::RemoteIp::IpSpoofAttackError
    nil
  end
end
