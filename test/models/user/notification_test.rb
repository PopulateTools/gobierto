require "test_helper"

class User::NotificationTest < ActiveSupport::TestCase
  def notification
    @notification ||= user_notifications(:dennis_consultation_created)
  end

  def test_valid
    assert notification.valid?
  end
end
