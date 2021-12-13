module LogrageHost
  extend ActiveSupport::Concern

  # This will add request's host to lograge
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
  end
end
