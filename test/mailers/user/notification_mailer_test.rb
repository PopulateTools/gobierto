require "test_helper"

class User::NotificationMailerTest < ActionMailer::TestCase
  def user_notification
    @user_notification ||= user_notifications(:dennis_consultation_created)
  end

  def user
    @user ||= user_notification.user
  end

  def test_single_notification
    email = User::NotificationMailer.single_notification(user_notification).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "A consultation has been added", email.subject
  end

  def test_notification_digest
    email = User::NotificationMailer.notification_digest(user, [user_notification], :daily).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Recent activity in your municipality", email.subject
  end
end
