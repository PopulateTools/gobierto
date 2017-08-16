# frozen_string_literal: true

require "test_helper"

class User::NotificationDigestAgentTest < ActiveSupport::TestCase
  def setup
    super
    @subject = User::NotificationDigestAgent.new(frequency)
  end

  def user
    @user ||= users(:dennis)
  end

  def frequency
    @frequency ||= user.notification_frequency
  end

  def test_call
    assert @subject.call
  end

  def test_call_with_invalid_frequency
    assert_raises(User::InvalidNotificationFrequency) do
      User::NotificationDigestAgent.new(:wadus).call
    end
  end

  def test_call_response
    assert_kind_of Array, @subject.call
  end
end
