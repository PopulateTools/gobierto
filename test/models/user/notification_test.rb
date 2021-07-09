# frozen_string_literal: true

require "test_helper"

class User::NotificationTest < ActiveSupport::TestCase
  def notification
    @notification ||= user_notifications(:dennis_post_published_sent_and_seen)
  end

  def sent_user_notification
    @sent_user_notification ||= user_notifications(:dennis_post_published_sent_and_seen)
  end

  def unsent_user_notification
    @unsent_user_notification ||= user_notifications(:dennis_post_published)
  end

  def seen_user_notification
    @seen_user_notification ||= user_notifications(:dennis_post_published_sent_and_seen)
  end

  def unseen_user_notification
    @unseen_user_notification ||= user_notifications(:dennis_post_published)
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

  def test_class_seen!
    assert User::Notification.unseen.any?

    User::Notification.seen!
    refute User::Notification.unseen.any?
  end

  def test_class_unseen!
    assert User::Notification.seen.any?

    User::Notification.unseen!
    refute User::Notification.seen.any?
  end

  def test_sent?
    assert sent_user_notification.sent?
    refute unsent_user_notification.sent?
  end

  def test_sent!
    refute unsent_user_notification.is_sent

    unsent_user_notification.sent!
    assert unsent_user_notification.is_sent
  end

  def test_unsent!
    assert sent_user_notification.is_sent

    sent_user_notification.unsent!
    refute sent_user_notification.is_sent
  end

  def test_seen?
    assert seen_user_notification.seen?
    refute unseen_user_notification.seen?
  end

  def test_seen!
    refute unseen_user_notification.is_seen

    unseen_user_notification.seen!
    assert unseen_user_notification.is_seen
  end

  def test_unseen!
    assert seen_user_notification.is_seen

    seen_user_notification.unseen!
    refute seen_user_notification.is_seen
  end
end
