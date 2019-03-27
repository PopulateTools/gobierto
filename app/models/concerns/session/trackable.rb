# frozen_string_literal: true

module Session::Trackable
  extend ActiveSupport::Concern

  def update_session_data(remote_ip, timestamp = Time.zone.now)
    update_columns(last_sign_in_ip: remote_ip, last_sign_in_at: timestamp)
  end
end
