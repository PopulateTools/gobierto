# frozen_string_literal: true

class User::NotificationForm < BaseForm

  attr_accessor(
    :user_id,
    :site_id,
    :action,
    :subject
  )

  validates :user_id, :site_id, :action, :subject, presence: true

  def save
    return unless valid?

    run_custom_callbacks if save_user_notification
  end

  def user_notification
    @user_notification ||= User::Notification.new
  end
  alias record user_notification

  private

  def user
    user_notification.user
  end

  def run_custom_callbacks
    return true unless deliver_notification_email?

    deliver_notification_email
    mark_as_sent
  end

  def save_user_notification
    @user_notification = user_notification.tap do |user_notification_attributes|
      user_notification_attributes.user_id = user_id
      user_notification_attributes.site_id = site_id
      user_notification_attributes.action = action
      user_notification_attributes.subject = subject
    end

    @user_notification.save(validate: false)
  end

  protected

  def deliver_notification_email?
    user.immediate_notifications?
  end

  def deliver_notification_email
    User::NotificationMailer.single_notification(user_notification).deliver_later(wait: 5.seconds)
  end

  def mark_as_sent
    user_notification.sent!
  end
end
