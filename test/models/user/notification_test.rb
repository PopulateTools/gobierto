require "test_helper"

class User::NotificationTest < ActiveSupport::TestCase
  def notification
    @notification ||= user_notifications(:dennis_consultation_created)
  end

  def sent_user_notification
    @sent_user_notification ||= user_notifications(:dennis_consultation_created)
  end

  def unsent_user_notification
    @unsent_user_notification ||= user_notifications(:dennis_consultation_title_changed)
  end

  def test_valid
    assert notification.valid?
  end

  def test_sent_scope
    assert_includes User::Notification.sent, sent_user_notification
    refute_includes User::Notification.sent, unsent_user_notification
  end

  def test_unsent_scope
    assert_includes User::Notification.unsent, unsent_user_notification
    refute_includes User::Notification.unsent, sent_user_notification
  end

  def test_class_sent!
    assert User::Notification.unsent.any?

    User::Notification.sent!
    refute User::Notification.unsent.any?
  end

  def test_class_unsent!
    assert User::Notification.sent.any?

    User::Notification.unsent!
    refute User::Notification.sent.any?
  end

  def test_sent!
    refute unsent_user_notification.sent?

    unsent_user_notification.sent!
    assert unsent_user_notification.sent?
  end

  def test_unsent!
    assert sent_user_notification.sent?

    sent_user_notification.unsent!
    refute sent_user_notification.sent?
  end
end
