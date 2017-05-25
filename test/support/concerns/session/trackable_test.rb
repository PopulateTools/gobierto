# frozen_string_literal: true

module Session::TrackableTest
  def test_update_session_data
    remote_ip = IPAddr.new('0.0.0.0')
    timestamp = Time.zone.now

    user.last_sign_in_ip = user.last_sign_in_at = nil

    assert_nil user.last_sign_in_ip
    assert_nil user.last_sign_in_at

    user.update_session_data(remote_ip, timestamp)
    assert_equal remote_ip, user.last_sign_in_ip
    assert_equal timestamp, user.last_sign_in_at
  end
end
