# frozen_string_literal: true

require 'test_helper'

class User::NotificationDigestTest < ActiveSupport::TestCase
  def setup
    super
    @subject = User::NotificationDigest.new(user.id, frequency)
  end

  def user
    @user ||= users(:dennis)
  end

  def user_notifications
    @user_notifications ||= user.notifications
  end

  def frequency
    @frequency ||= user.notification_frequency
  end

  def test_call
    assert @subject.call
  end

  def test_call_response
    assert_equal [user.id, user_notifications.unsent.count], @subject.call
  end

  def test_notification_digest_deliveries
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      @subject.call
    end
  end
end
