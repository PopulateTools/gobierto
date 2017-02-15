require "test_helper"

class GobiertoCommon::ActiveNotifier::DailyTest < ActiveSupport::TestCase
  def setup
    super
    @subject = GobiertoCommon::ActiveNotifier::Daily
  end

  def test_notifications
    assert_difference "User::Notification.count", 2 do
      assert @subject.call
    end
  end
end
