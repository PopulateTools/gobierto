# frozen_string_literal: true

class User::NotificationDigest
  attr_reader :user_id, :frequency

  def initialize(user_id, frequency)
    @user_id = user_id
    @frequency = frequency
  end

  def call
    if user_notifications.any?
      deliver_notification_digest
      mark_as_sent
    end

    [user_id, user_notifications.size]
  end

  private

  def deliver_notification_digest
    User::NotificationMailer.notification_digest(
      user,
      user_notifications.to_a,
      frequency.to_s
    ).deliver_later
  end

  def mark_as_sent
    user_notifications.sent!
  end

  protected

  def user
    @user ||= User.find_by(id: user_id)
  end

  def user_notifications
    @user_notifications ||= User::Notification.unsent.where(user_id: user_id)
  end
end
